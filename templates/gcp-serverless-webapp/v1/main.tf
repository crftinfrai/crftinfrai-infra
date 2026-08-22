terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "project_id" {
  description = "Google Cloud project ID for the deployment."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the Cloud Run service."
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Lowercase prefix used for resource labels and names."
  type        = string
  default     = "crft-web"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 4-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "cloudrun_service_name" {
  description = "Name of the Cloud Run v2 service."
  type        = string
  default     = "crft-web"
}

variable "container_image" {
  description = "Container image URI. Replace the public sample image with your application image."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "container_port" {
  description = "Port exposed by the Cloud Run container."
  type        = number
  default     = 8080

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "cloudrun_cpu" {
  description = "Cloud Run v2 CPU limit, such as 1 or 2."
  type        = string
  default     = "1"
}

variable "cloudrun_memory" {
  description = "Cloud Run v2 memory limit, such as 512Mi or 1Gi."
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances >= 0
    error_message = "min_instances must be zero or greater."
  }
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 5

  validation {
    condition     = var.max_instances >= 1
    error_message = "max_instances must be at least 1."
  }
}

variable "request_timeout_seconds" {
  description = "Maximum Cloud Run request timeout in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.request_timeout_seconds >= 1 && var.request_timeout_seconds <= 3600
    error_message = "request_timeout_seconds must be between 1 and 3600 seconds."
  }
}

variable "container_concurrency" {
  description = "Maximum concurrent requests per Cloud Run instance."
  type        = number
  default     = 80

  validation {
    condition     = var.container_concurrency >= 1 && var.container_concurrency <= 1000
    error_message = "container_concurrency must be between 1 and 1000."
  }
}

variable "allow_unauthenticated" {
  description = "Grant roles/run.invoker to allUsers when true."
  type        = bool
  default     = false
}

variable "ingress" {
  description = "Cloud Run ingress policy."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"

  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
    ], var.ingress)
    error_message = "ingress must be a supported Cloud Run v2 ingress value."
  }
}

variable "environment" {
  description = "Non-secret environment variables passed to the container."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels applied to the Cloud Run service."
  type        = map(string)
  default     = {}
}

# --------------------------------------------------
# Required APIs and labels
# --------------------------------------------------

locals {
  required_services = toset([
    "iam.googleapis.com",
    "run.googleapis.com",
  ])

  service_labels = merge({
    managed_by = "terraform"
    template   = "gcp-serverless-webapp"
  }, var.labels)
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

check "instance_bounds" {
  assert {
    condition     = var.min_instances <= var.max_instances
    error_message = "min_instances must be less than or equal to max_instances."
  }
}

# --------------------------------------------------
# Cloud Run service account
# --------------------------------------------------

resource "google_service_account" "cloudrun" {
  account_id   = "${var.name_prefix}-run"
  project      = var.project_id
  display_name = "Cloud Run runtime identity"

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

# --------------------------------------------------
# Cloud Run v2
# --------------------------------------------------

resource "google_cloud_run_v2_service" "main" {
  name                = var.cloudrun_service_name
  project             = var.project_id
  location            = var.region
  ingress             = var.ingress
  deletion_protection = false
  labels              = local.service_labels

  template {
    service_account                  = google_service_account.cloudrun.email
    timeout                          = "${var.request_timeout_seconds}s"
    max_instance_request_concurrency = var.container_concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.container_image

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cloudrun_cpu
          memory = var.cloudrun_memory
        }
      }

      dynamic "env" {
        for_each = var.environment

        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [google_project_service.required["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_unauthenticated ? 1 : 0

  project  = var.project_id
  location = google_cloud_run_v2_service.main.location
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "project_id" {
  description = "Google Cloud project containing the service."
  value       = var.project_id
}

output "region" {
  description = "Google Cloud region containing the service."
  value       = var.region
}

output "cloud_run_service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.main.name
}

output "cloud_run_url" {
  description = "Cloud Run service URL."
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_run_service_account_email" {
  description = "Cloud Run runtime service account email."
  value       = google_service_account.cloudrun.email
}
