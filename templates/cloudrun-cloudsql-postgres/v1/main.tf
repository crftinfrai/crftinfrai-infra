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
  description = "Google Cloud region for Cloud Run and Cloud SQL."
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Lowercase prefix used for resource names."
  type        = string
  default     = "crft-serverless"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 4-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "network_name" {
  description = "Name of the custom VPC network."
  type        = string
  default     = "crft-serverless-vpc"
}

variable "vpc_subnet_cidr" {
  description = "Primary CIDR range for the Cloud Run direct VPC egress subnet."
  type        = string
  default     = "10.60.0.0/24"
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

variable "cloudrun_min_instances" {
  description = "Minimum number of Cloud Run instances."
  type        = number
  default     = 0

  validation {
    condition     = var.cloudrun_min_instances >= 0
    error_message = "cloudrun_min_instances must be zero or greater."
  }
}

variable "cloudrun_max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 5

  validation {
    condition     = var.cloudrun_max_instances >= 1
    error_message = "cloudrun_max_instances must be at least 1."
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

variable "cloudrun_timeout_seconds" {
  description = "Maximum request timeout for Cloud Run."
  type        = number
  default     = 300

  validation {
    condition     = var.cloudrun_timeout_seconds >= 1 && var.cloudrun_timeout_seconds <= 3600
    error_message = "cloudrun_timeout_seconds must be between 1 and 3600 seconds."
  }
}

variable "cloudrun_concurrency" {
  description = "Maximum concurrent requests per Cloud Run instance."
  type        = number
  default     = 80

  validation {
    condition     = var.cloudrun_concurrency >= 1 && var.cloudrun_concurrency <= 1000
    error_message = "cloudrun_concurrency must be between 1 and 1000."
  }
}

variable "cloudrun_ingress" {
  description = "Cloud Run ingress policy."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"

  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
    ], var.cloudrun_ingress)
    error_message = "cloudrun_ingress must be a supported Cloud Run v2 ingress value."
  }
}

variable "allow_unauthenticated" {
  description = "Grant roles/run.invoker to allUsers when true."
  type        = bool
  default     = false
}

variable "cloudsql_instance_name" {
  description = "Name of the private Cloud SQL PostgreSQL instance."
  type        = string
  default     = "crft-postgres"
}

variable "cloudsql_database_name" {
  description = "Initial database created in Cloud SQL."
  type        = string
  default     = "appdb"
}

variable "cloudsql_version" {
  description = "Cloud SQL PostgreSQL database version."
  type        = string
  default     = "POSTGRES_16"
}

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-2-7680"
}

variable "cloudsql_disk_size_gb" {
  description = "Cloud SQL SSD storage size in GiB."
  type        = number
  default     = 50

  validation {
    condition     = var.cloudsql_disk_size_gb >= 10
    error_message = "cloudsql_disk_size_gb must be at least 10 GiB."
  }
}

variable "db_username" {
  description = "Cloud SQL PostgreSQL application user name."
  type        = string
  default     = "appadmin"
}

variable "db_password" {
  description = "Cloud SQL PostgreSQL application user password. Supply through a protected variable or TF_VAR_db_password."
  type        = string
  sensitive   = true
  default     = null
}

variable "environment" {
  description = "Non-secret environment variables passed to Cloud Run."
  type        = map(string)
  default     = {}
}

# --------------------------------------------------
# APIs and labels
# --------------------------------------------------

locals {
  required_services = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ])

  common_labels = {
    managed_by = "terraform"
    template   = "cloudrun-cloudsql-postgres"
  }
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

check "cloudrun_instance_bounds" {
  assert {
    condition     = var.cloudrun_min_instances <= var.cloudrun_max_instances
    error_message = "cloudrun_min_instances must be less than or equal to cloudrun_max_instances."
  }
}

# --------------------------------------------------
# Custom VPC and direct Cloud Run egress subnet
# --------------------------------------------------

resource "google_compute_network" "main" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

resource "google_compute_subnetwork" "cloudrun" {
  name                     = "${var.name_prefix}-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.vpc_subnet_cidr
  private_ip_google_access = true
}

# --------------------------------------------------
# Private Services Access for Cloud SQL
# --------------------------------------------------

resource "google_compute_global_address" "private_service_range" {
  name          = "${var.name_prefix}-private-services"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.70.0.0"
  prefix_length = 16
  network       = google_compute_network.main.id

  depends_on = [google_project_service.required["servicenetworking.googleapis.com"]]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]

  depends_on = [google_project_service.required["servicenetworking.googleapis.com"]]
}

# --------------------------------------------------
# Private Cloud SQL PostgreSQL
# --------------------------------------------------

resource "google_sql_database_instance" "postgres" {
  name                = var.cloudsql_instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.cloudsql_version
  deletion_protection = true

  settings {
    tier              = var.cloudsql_tier
    disk_type         = "PD_SSD"
    disk_size         = var.cloudsql_disk_size_gb
    disk_autoresize   = true
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }

    user_labels = local.common_labels
  }

  depends_on = [
    google_project_service.required["sqladmin.googleapis.com"],
    google_service_networking_connection.private_vpc_connection,
  ]
}

resource "google_sql_database" "main" {
  name     = var.cloudsql_database_name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "main" {
  name     = var.db_username
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# --------------------------------------------------
# Cloud Run service account and IAM
# --------------------------------------------------

resource "google_service_account" "cloudrun" {
  account_id   = "${var.name_prefix}-run"
  project      = var.project_id
  display_name = "Cloud Run workload identity"

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# --------------------------------------------------
# Cloud Run v2 service
# --------------------------------------------------

resource "google_cloud_run_v2_service" "main" {
  name                = var.cloudrun_service_name
  project             = var.project_id
  location            = var.region
  ingress             = var.cloudrun_ingress
  deletion_protection = false

  template {
    service_account                  = google_service_account.cloudrun.email
    timeout                          = "${var.cloudrun_timeout_seconds}s"
    max_instance_request_concurrency = var.cloudrun_concurrency

    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"

      network_interfaces {
        network    = google_compute_network.main.name
        subnetwork = google_compute_subnetwork.cloudrun.name
      }
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

      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.postgres.private_ip_address
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_NAME"
        value = var.cloudsql_database_name
      }

      env {
        name  = "DB_USER"
        value = var.db_username
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

  depends_on = [
    google_project_service.required["run.googleapis.com"],
    google_project_iam_member.cloudsql_client,
    google_sql_database.main,
    google_sql_user.main,
  ]
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
  description = "Google Cloud project containing the deployment."
  value       = var.project_id
}

output "region" {
  description = "Google Cloud region containing the deployment."
  value       = var.region
}

output "network_name" {
  description = "Custom VPC network name."
  value       = google_compute_network.main.name
}

output "cloud_run_service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.main.name
}

output "cloud_run_url" {
  description = "Cloud Run service URL."
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_sql_instance_name" {
  description = "Private Cloud SQL instance name."
  value       = google_sql_database_instance.postgres.name
}

output "cloud_sql_private_ip" {
  description = "Private IP address assigned to Cloud SQL."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "cloud_sql_database_name" {
  description = "Cloud SQL database name."
  value       = google_sql_database.main.name
}

output "cloud_run_service_account_email" {
  description = "Cloud Run workload service account email."
  value       = google_service_account.cloudrun.email
}
