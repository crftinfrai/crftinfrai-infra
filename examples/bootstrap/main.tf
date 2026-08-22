
terraform {
  required_version = ">= 1.6.0"
  backend "local" {}
}

module "backend_state" {
  source              = "../../bootstrap/backend-state"
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  aws_region          = var.aws_region
  aws_profile         = var.aws_profile
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for encrypted Terraform state."
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional local AWS CLI profile name."
  type        = string
  default     = null
}

output "bucket_name" {
  value = module.backend_state.bucket_name
}

output "dynamodb_table_name" {
  value = module.backend_state.dynamodb_table_name
}
