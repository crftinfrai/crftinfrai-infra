terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10, < 3.0"
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
  description = "Google Cloud region for the regional GKE cluster and Cloud SQL instance."
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zones used by the regional GKE node pool."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]

  validation {
    condition     = length(var.zones) >= 2
    error_message = "At least two zones are required for the regional GKE node pool."
  }
}

variable "name_prefix" {
  description = "Lowercase prefix used in resource names."
  type        = string
  default     = "crft-gke"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 3-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "network_name" {
  description = "Name of the custom VPC network."
  type        = string
  default     = "crft-gke-vpc"
}

variable "subnet_name" {
  description = "Name of the GKE subnet."
  type        = string
  default     = "crft-gke-subnet"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the GKE subnet."
  type        = string
  default     = "10.20.0.0/20"
}

variable "pods_secondary_range_name" {
  description = "Name of the subnet secondary range used for GKE pods."
  type        = string
  default     = "gke-pods"
}

variable "pods_secondary_cidr" {
  description = "Secondary CIDR range used for GKE pods."
  type        = string
  default     = "10.24.0.0/14"
}

variable "services_secondary_range_name" {
  description = "Name of the subnet secondary range used for GKE services."
  type        = string
  default     = "gke-services"
}

variable "services_secondary_cidr" {
  description = "Secondary CIDR range used for GKE services."
  type        = string
  default     = "10.28.0.0/20"
}

variable "cluster_name" {
  description = "Name of the regional GKE cluster."
  type        = string
  default     = "crft-gke-prod"
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "gke_machine_type" {
  description = "Machine type for GKE worker nodes."
  type        = string
  default     = "e2-standard-4"
}

variable "gke_node_min_count" {
  description = "Minimum number of nodes per zone in the managed node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.gke_node_min_count >= 1
    error_message = "gke_node_min_count must be at least 1 per zone."
  }
}

variable "gke_node_max_count" {
  description = "Maximum number of nodes per zone in the managed node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.gke_node_max_count >= var.gke_node_min_count
    error_message = "gke_node_max_count must be greater than or equal to gke_node_min_count."
  }
}

variable "gke_node_initial_count" {
  description = "Initial number of nodes per zone in the managed node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.gke_node_initial_count >= 1
    error_message = "gke_node_initial_count must be at least 1 per zone."
  }
}

variable "gke_disk_size_gb" {
  description = "Persistent boot disk size for GKE nodes in GiB."
  type        = number
  default     = 100

  validation {
    condition     = var.gke_disk_size_gb >= 20
    error_message = "gke_disk_size_gb must be at least 20 GiB."
  }
}

variable "gke_disk_type" {
  description = "Persistent boot disk type for GKE nodes."
  type        = string
  default     = "pd-balanced"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.gke_disk_type)
    error_message = "gke_disk_type must be pd-standard, pd-balanced, or pd-ssd."
  }
}

variable "cloudsql_instance_name" {
  description = "Name of the private Cloud SQL PostgreSQL instance."
  type        = string
  default     = "crft-postgres-prod"
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
  description = "Cloud SQL disk size in GiB."
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

variable "master_authorized_cidrs" {
  description = "CIDR blocks allowed to reach the GKE control-plane endpoint. Replace the default private range with the actual Terraform/administrator egress CIDRs."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "private-network"
    }
  ]

  validation {
    condition = alltrue([
      for entry in var.master_authorized_cidrs : can(cidrhost(entry.cidr_block, 0)) && entry.cidr_block != "0.0.0.0/0"
    ])
    error_message = "master_authorized_cidrs must contain valid CIDRs and must not include 0.0.0.0/0."
  }
}

# --------------------------------------------------
# Required Google APIs
# --------------------------------------------------

locals {
  required_services = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ])

  common_labels = {
    managed_by = "terraform"
    template   = "gke-cloudsql-argocd"
  }
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# --------------------------------------------------
# VPC, subnet, secondary ranges, and Cloud NAT
# --------------------------------------------------

resource "google_compute_network" "main" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

resource "google_compute_subnetwork" "gke" {
  name                     = var.subnet_name
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = var.pods_secondary_range_name
    ip_cidr_range = var.pods_secondary_cidr
  }

  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.services_secondary_cidr
  }
}

resource "google_compute_router" "nat" {
  name    = "${var.name_prefix}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.main.id

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.name_prefix}-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.nat.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# --------------------------------------------------
# Private Services Access for Cloud SQL
# --------------------------------------------------

resource "google_compute_global_address" "private_service_range" {
  name          = "${var.name_prefix}-private-services"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.50.0.0"
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
# Regional GKE cluster
# --------------------------------------------------

resource "google_container_cluster" "main" {
  name                     = var.cluster_name
  project                  = var.project_id
  location                 = var.region
  networking_mode          = "VPC_NATIVE"
  network                  = google_compute_network.main.name
  subnetwork               = google_compute_subnetwork.gke.name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_cidrs

      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  depends_on = [
    google_project_service.required["container.googleapis.com"],
    google_compute_subnetwork.gke,
  ]

  resource_labels = local.common_labels
}

resource "google_container_node_pool" "main" {
  name           = "${var.name_prefix}-nodes"
  project        = var.project_id
  location       = var.region
  cluster        = google_container_cluster.main.name
  node_locations = var.zones

  initial_node_count = var.gke_node_initial_count

  autoscaling {
    min_node_count = var.gke_node_min_count
    max_node_count = var.gke_node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.gke_machine_type
    disk_size_gb = var.gke_disk_size_gb
    disk_type    = var.gke_disk_type
    image_type   = "COS_CONTAINERD"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  depends_on = [google_project_service.required["container.googleapis.com"]]
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
# Helm provider and Argo CD
# --------------------------------------------------

data "google_client_config" "current" {
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.main.endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.0"
  namespace        = "argocd"
  create_namespace = true
  wait             = true

  depends_on = [google_container_node_pool.main]
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

output "subnet_name" {
  description = "GKE subnet name."
  value       = google_compute_subnetwork.gke.name
}

output "gke_cluster_name" {
  description = "Regional GKE cluster name."
  value       = google_container_cluster.main.name
}

output "gke_cluster_location" {
  description = "Regional GKE cluster location."
  value       = google_container_cluster.main.location
}

output "cloudsql_instance_name" {
  description = "Private Cloud SQL instance name."
  value       = google_sql_database_instance.postgres.name
}

output "cloudsql_private_ip" {
  description = "Private IP address assigned to Cloud SQL."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "cloudsql_database_name" {
  description = "Cloud SQL database name."
  value       = google_sql_database.main.name
}

output "argocd_namespace" {
  description = "Namespace in which Argo CD is installed."
  value       = helm_release.argocd.namespace
}
