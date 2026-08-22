// filename: main.tf

locals {
  create_net       = var.network_mode == "create"
  use_existing_net = var.network_mode == "existing"

  # AMI lookup if not provided (Ubuntu 22.04 LTS)
  use_ami_lookup = var.ami_id == null || var.ami_id == ""
}

############################
# (Optional) Network
############################
resource "aws_vpc" "this" {
  count                = local.create_net ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  count  = local.create_net ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

resource "aws_subnet" "public" {
  count                   = local.create_net ? 1 : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-public-subnet" })
}

resource "aws_route_table" "public" {
  count  = local.create_net ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rtb-public" })
}

resource "aws_route" "default_inet" {
  count                  = local.create_net ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public_assoc" {
  count          = local.create_net ? 1 : 0
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# Select network IDs based on mode
locals {
  vpc_id    = local.create_net ? aws_vpc.this[0].id : var.existing_vpc_id
  subnet_id = local.create_net ? aws_subnet.public[0].id : var.existing_subnet_id
}

############################
# Security Group
############################
resource "aws_security_group" "vm_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow SSH/HTTP/HTTPS"
  vpc_id      = local.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-sg" })

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.ssh_cidrs
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# Key pair (optional)
############################
resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.name_prefix}-key"
  public_key = var.ssh_public_key
  tags       = merge(var.tags, { Name = "${var.name_prefix}-key" })
}

############################
# AMI lookup (Ubuntu 22.04)
############################
data "aws_ami" "ubuntu" {
  count       = local.use_ami_lookup ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

locals {
  final_ami = local.use_ami_lookup ? data.aws_ami.ubuntu[0].id : var.ami_id
}

############################
# EC2 Instance
############################
resource "aws_instance" "vm" {
  ami                         = local.final_ami
  instance_type               = "t3.medium"
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.vm_sg.id]
  associate_public_ip_address = var.create_public_ip

  key_name = var.create_key_pair ? aws_key_pair.this[0].key_name : var.existing_key_name

  user_data = var.user_data

  root_block_device {
    volume_size = 100 //var.root_volume_size_gb
    volume_type = var.root_volume_type
  }

  tags = merge(var.tags, { Name = var.instance_name })
}

# Optional Elastic IP (alloc & attach)
resource "aws_eip" "this" {
  count  = var.create_public_ip && var.allocate_eip ? 1 : 0
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-eip" })
}

resource "aws_eip_association" "assoc" {
  count         = var.create_public_ip && var.allocate_eip ? 1 : 0
  allocation_id = aws_eip.this[0].id
  instance_id   = aws_instance.vm.id
}

resource "aws_ebs_volume" "web_ebs_vol" {
  availability_zone = var.availability_zone # Set availability zone based on your region and preferences
  size              = 100
  type              = "gp3" # Volume type (e.g., gp2, io1)

  tags = {
    Name        = "web-ebs-volume"
    Environment = "${var.environment}" # Set environment tag (e.g., dev, staging, prod)
  }
}

############################
# Route53 (optional)
############################
resource "aws_route53_zone" "zone" {
  count = var.create_dns_zone ? 1 : 0
  name  = var.root_domain
  tags  = merge(var.tags, { Name = "${var.name_prefix}-zone" })
}

resource "aws_route53_record" "a_record" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = var.create_dns_zone ? aws_route53_zone.zone[0].zone_id : var.existing_zone_id
  name    = "${var.subdomain}.${var.root_domain}"
  type    = "A"
  ttl     = 300
  records = [coalesce(
    try(aws_eip.this[0].public_ip, ""),
    aws_instance.vm.public_ip
  )]
}
