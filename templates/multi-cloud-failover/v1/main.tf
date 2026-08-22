terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "aws_region" {
  description = "AWS region hosting the primary static site."
  type        = string
  default     = "us-east-1"
}

variable "gcp_project_id" {
  description = "Google Cloud project hosting the secondary static site."
  type        = string
}

variable "gcp_region" {
  description = "Google Cloud region associated with the secondary site."
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Lowercase prefix used in resource names."
  type        = string
  default     = "crft-failover"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.name_prefix))
    error_message = "name_prefix must be 3-20 characters using lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Environment label applied to both cloud resources."
  type        = string
  default     = "failover-ready"
}

variable "aws_bucket_name" {
  description = "Globally unique S3 bucket name for the primary static site."
  type        = string
  default     = "crft-multicloud-primary-site"
}

variable "gcp_bucket_name" {
  description = "Globally unique Google Cloud Storage bucket name for the secondary static site."
  type        = string
  default     = "crft-multicloud-secondary-site"
}

# --------------------------------------------------
# Shared labels and required Google APIs
# --------------------------------------------------

locals {
  aws_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Product     = "CrftInfrai"
  }

  gcp_labels = {
    environment = var.environment
    managed_by  = "terraform"
    product     = "crftinfrai"
  }
}

resource "google_project_service" "storage" {
  project            = var.gcp_project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# --------------------------------------------------
# Primary AWS static website
# --------------------------------------------------

resource "aws_s3_bucket" "primary" {
  bucket        = var.aws_bucket_name
  force_destroy = true

  tags = merge(local.aws_tags, {
    Name = var.aws_bucket_name
    Role = "primary"
  })
}

resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_policy" "primary_public_read" {
  bucket = aws_s3_bucket.primary.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadForStaticWebsite"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.primary.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.primary]
}

# --------------------------------------------------
# Secondary Google Cloud Storage static website
# --------------------------------------------------

resource "google_storage_bucket" "secondary" {
  name                        = var.gcp_bucket_name
  project                     = var.gcp_project_id
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  labels = local.gcp_labels

  depends_on = [google_project_service.storage]
}

resource "google_storage_bucket_iam_member" "secondary_public_read" {
  bucket = google_storage_bucket.secondary.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# --------------------------------------------------
# Outputs: endpoints and failover status
# --------------------------------------------------

output "primary_provider" {
  description = "Provider hosting the primary static site."
  value       = "aws"
}

output "primary_region" {
  description = "AWS region hosting the primary static site."
  value       = var.aws_region
}

output "primary_endpoint" {
  description = "Actual S3 website endpoint for the primary site."
  value       = aws_s3_bucket_website_configuration.primary.website_endpoint
}

output "primary_bucket_name" {
  description = "Primary S3 bucket name."
  value       = aws_s3_bucket.primary.bucket
}

output "secondary_provider" {
  description = "Provider hosting the secondary static site."
  value       = "gcp"
}

output "secondary_region" {
  description = "Google Cloud region hosting the secondary static site."
  value       = var.gcp_region
}

output "secondary_endpoint" {
  description = "Google Cloud Storage URL for the secondary static site."
  value       = "https://storage.googleapis.com/${google_storage_bucket.secondary.name}/index.html"
}

output "secondary_bucket_name" {
  description = "Secondary Google Cloud Storage bucket name."
  value       = google_storage_bucket.secondary.name
}

output "failover_mode" {
  description = "Traffic failover model provided by this template."
  value       = "external-manual"
}
