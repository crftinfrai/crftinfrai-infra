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
variable "bucket_name" {
  type    = string
  default = null
}
variable "force_destroy" {
  type    = bool
  default = false
}
