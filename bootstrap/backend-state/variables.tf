variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = null
}
variable "bucket_name" {
  type = string
}
variable "dynamodb_table_name" {
  type = string
}
variable "kms_key_id" {
  type    = string
  default = ""
}
variable "force_destroy" {
  type    = bool
  default = false
}
