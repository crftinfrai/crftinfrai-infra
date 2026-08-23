locals {
  common_labels = var.labels
}

# Network (VPC + subnet + private service access)
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.network_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.21.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.22.0.0/16"
  }
}

# Private Service Connect for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

resource "google_compute_global_address" "private_service_range" {
  name          = "google-managed-services-${var.network_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# GKE (Workload Identity, private cluster, release channel)
resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  release_channel { channel = var.release_channel }
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes   = var.enable_private_nodes
    master_ipv4_cidr_block = var.master_cidr
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_config { enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"] }
  monitoring_config { enable_components = ["SYSTEM_COMPONENTS"] }

  deletion_protection = false
  resource_labels     = local.common_labels

  # default node pool removed; use managed node pool
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "np" {
  name       = "${var.cluster_name}-np"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 2
  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = local.common_labels
    metadata     = { disable-legacy-endpoints = "true" }
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Cloud SQL (Postgres) with private IP
resource "google_sql_database_instance" "db" {
  name             = "${var.cluster_name}-pg"
  database_version = var.db_version
  region           = var.region

  settings {
    tier        = var.db_tier
    user_labels = local.common_labels
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
    availability_type = "REGIONAL"
    disk_autoresize   = true
  }

  deletion_protection = true
}

resource "google_sql_user" "db_user" {
  instance = google_sql_database_instance.db.name
  name     = var.database_user
  password = var.database_password
}

resource "google_sql_database" "db_main" {
  name     = var.database_name
  instance = google_sql_database_instance.db.name
}

# Ingress (GCLB) via NEG is typically configured via Kubernetes Ingress controllers.
# Here we just create a reserved IP for later use.
resource "google_compute_global_address" "ingress_ip" {
  name = "${var.cluster_name}-ingress-ip"
}

output "vpc_name" { value = google_compute_network.vpc.name }
output "subnet_name" { value = google_compute_subnetwork.subnet.name }
output "cluster_name" { value = google_container_cluster.gke.name }
output "db_instance" { value = google_sql_database_instance.db.name }
output "ingress_ip" { value = google_compute_global_address.ingress_ip.address }
