terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "region" {
  description = "AWS region for the development instance."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used in resource names and tags."
  type        = string
  default     = "crft-dev"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.name_prefix))
    error_message = "name_prefix must be 3-20 characters using lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the small development VPC."
  type        = string
  default     = "10.90.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the single public development subnet."
  type        = string
  default     = "10.90.1.0/24"
}

variable "instance_type" {
  description = "Small EC2 instance type for the development host."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Encrypted gp3 root volume size in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 100
    error_message = "root_volume_size_gb must be between 8 and 100 GiB for this lightweight template."
  }
}

variable "http_ingress_cidr" {
  description = "CIDR allowed to reach the demo HTTP server. Restrict this for shared environments."
  type        = string
  default     = "0.0.0.0/0"
}

# --------------------------------------------------
# Availability zone and tags
# --------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  availability_zone = data.aws_availability_zones.available.names[0]

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Product     = "CrftInfrai"
  }
}

# --------------------------------------------------
# Minimal single-zone networking
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-route-table"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# Development security group
# --------------------------------------------------

resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-web-"
  description = "HTTP access to the temporary development host."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Demo HTTP service"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_ingress_cidr]
  }

  egress {
    description = "Development host outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

# --------------------------------------------------
# Small development instance
# --------------------------------------------------

resource "aws_instance" "main" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOT
    #!/bin/bash
    set -e
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!doctype html>
    <html><head><title>CrftInfrai Dev/Test</title></head>
    <body><h1>CrftInfrai development host</h1><p>Temporary AWS dev/test environment.</p></body></html>
    HTML
    systemctl enable --now nginx
  EOT

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-instance"
  })
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "region" {
  description = "AWS region containing the development resources."
  value       = var.region
}

output "vpc_id" {
  description = "Development VPC ID."
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Single public development subnet ID."
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "Development EC2 instance ID."
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP address of the development instance."
  value       = aws_instance.main.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the development instance."
  value       = aws_instance.main.public_dns
}
