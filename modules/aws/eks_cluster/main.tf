// filename: main.tf

locals {
  default_tags = {
    Project     = "CrftInfrai"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  create_net = var.network_mode == "create"

  # AZ selection:
  # - If user provides var.azs, use that
  # - Else auto-pick the first N AZs based on subnet CIDRs
  selected_azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, length(var.create_subnet_cidrs))

  # Merge default + user tags
  tags = merge(local.default_tags, var.tags)
}

data "aws_availability_zones" "available" {}

# -------------------------
# VPC (minimal) - when network_mode=create
# NOTE: This creates PUBLIC subnets only (quickstart network).
# For production posture, add private subnets + NAT (v2 blueprint).
# -------------------------
resource "aws_vpc" "this" {
  count                = local.create_net ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  count  = local.create_net ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(local.tags, { Name = "${var.name_prefix}-igw" })
}

resource "aws_subnet" "subnet" {
  count                   = local.create_net ? length(var.create_subnet_cidrs) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.create_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${var.name_prefix}-subnet-${count.index}" })
}

resource "aws_route_table" "rt" {
  count  = local.create_net ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(local.tags, { Name = "${var.name_prefix}-rt" })
}

resource "aws_route" "default" {
  count                  = local.create_net ? 1 : 0
  route_table_id         = aws_route_table.rt[0].id
  gateway_id             = aws_internet_gateway.igw[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "assoc" {
  count          = local.create_net ? length(aws_subnet.subnet) : 0
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rt[0].id
}

locals {
  subnet_ids = local.create_net ? [for s in aws_subnet.subnet : s.id] : var.existing_subnet_ids
  vpc_id     = local.create_net ? aws_vpc.this[0].id : var.existing_vpc_id
}

# -------------------------
# IAM for EKS Cluster
# -------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.name_prefix}-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster_A" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_B" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_VPCResourceController"
}

resource "aws_security_group" "cluster" {
  name   = "${var.name_prefix}-eks-cluster-sg"
  vpc_id = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# -------------------------
# EKS Cluster
# -------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = local.subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.api_public_access_cidrs
  }

  tags = local.tags
}

# -------------------------
# IAM for Node Group
# -------------------------
resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-eks-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "node_A" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_B" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_C" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -------------------------
# Managed Node Group
# -------------------------
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size
  ami_type       = var.node_ami_type
  capacity_type  = var.node_capacity_type

  labels = var.node_labels
  tags   = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.node_A,
    aws_iam_role_policy_attachment.node_B,
    aws_iam_role_policy_attachment.node_C
  ]
}
