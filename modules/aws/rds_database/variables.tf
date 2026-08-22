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
variable "identifier" {
  type    = string
  default = "crft-postgres"
}
variable "engine" {
  type    = string
  default = "postgres"
}
variable "engine_version" {
  type    = string
  default = null
}
variable "instance_class" {
  type    = string
  default = "db.t3.small"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "db_name" {
  type    = string
  default = "appdb"
}
variable "username" {
  type    = string
  default = "admin"
}
variable "password" {
  type      = string
  sensitive = true
}
