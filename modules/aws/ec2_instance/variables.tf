// filename: variables.tf

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = null
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "availability_zone" {
  type    = string
  default = null
}

variable "name_prefix" {
  type    = string
  default = "web"
}
variable "instance_name" {
  type    = string
  default = "web-ec2"
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "az" {
  type    = string
  default = null
}
# Network: create or existing
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}
variable "existing_vpc_id" {
  type    = string
  default = null
}
variable "existing_subnet_id" {
  type    = string
  default = null
}
# SSH & Key
variable "ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "create_key_pair" {
  type    = bool
  default = true
}
variable "ssh_public_key" {
  type    = string
  default = ""
}
variable "existing_key_name" {
  type    = string
  default = null
}
# AMI (optional override)
variable "ami_id" {
  type    = string
  default = null
}
# Disks
variable "root_volume_size_gb" {
  type    = number
  default = 50
}
variable "root_volume_type" {
  type    = string
  default = "gp3"
}
# Networking (public IP/EIP)
variable "create_public_ip" {
  type    = bool
  default = true
}
variable "allocate_eip" {
  type    = bool
  default = true
}
# User data
variable "user_data" {
  type    = string
  default = ""
}
# DNS
variable "create_dns_zone" {
  type    = bool
  default = false
}
variable "create_dns_record" {
  type    = bool
  default = false
}
variable "root_domain" {
  type    = string
  default = ""
}
variable "subdomain" {
  type    = string
  default = "app"
}
variable "existing_zone_id" {
  type    = string
  default = null
}
# Tags
variable "tags" {
  type    = map(string)
  default = { env = "prod", app = "web" }
}
