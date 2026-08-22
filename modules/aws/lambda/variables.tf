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
variable "name" {
  type    = string
  default = "crft-lambda"
}
variable "runtime" {
  type    = string
  default = "nodejs20.x"
}
variable "handler" {
  type    = string
  default = "index.handler"
}
variable "filename" {
  type    = string
  default = "lambda_function_payload.zip"
}
variable "memory_size" {
  type    = number
  default = 512
}
variable "timeout" {
  type    = number
  default = 30
}
variable "architecture" {
  type    = string
  default = "x86_64"
}
