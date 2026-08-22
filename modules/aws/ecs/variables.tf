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
variable "cluster_name" {
  type    = string
  default = "crft-ecs"
}
variable "service_name" {
  type    = string
  default = "crft-service"
}
variable "container_name" {
  type    = string
  default = "app"
}
variable "container_image" {
  type    = string
  default = "nginx:latest"
}
variable "container_port" {
  type    = number
  default = 80
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}
variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.60.1.0/24", "10.60.2.0/24"]
}
