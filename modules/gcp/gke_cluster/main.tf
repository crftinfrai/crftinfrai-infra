// filename: main.tf

locals {
  create_net       = var.network_mode == "create"
  use_existing_net = var.network_mode == "existing"

  master_auth_cidrs = length(var.master_authorized_cidrs) > 0 ? var.master_authorized_cidrs : ["0.0.0.0/0"]
}

# (Optional) Enable APIs
resource "google_project_service" "container" {
  count   = var.enable_apis ? 1 : 0
  project = var.project_id
  service = "container.googleapis.com"
}

# Network (create)
resource "google_compute_network" "vpc" {
  count                   = local.create_net ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = local.create_net ? 1 : 0
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc[0].id
  ip_cidr_range = var.subnet_cidr
  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_cidr
  }
}

# Network (existing)
data "google_compute_network" "existing" {
  count = local.use_existing_net ? 1 : 0
  name  = var.existing_vpc_name
}

data "google_compute_subnetwork" "existing" {
  count   = local.use_existing_net ? 1 : 0
  name    = var.existing_subnet_name
  region  = var.region
  project = var.project_id
}

locals {
  subnetwork_self_link = local.create_net ? google_compute_subnetwork.subnet[0].self_link : data.google_compute_subnetwork.existing[0].self_link
  pods_range_name      = local.create_net ? var.pods_range_name : var.existing_pods_range_name
  services_range_name  = local.create_net ? var.services_range_name : var.existing_services_range_name
}

# Cluster
resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.location # region or zone
  project  = var.project_id

  network    = local.create_net ? google_compute_network.vpc[0].self_link : data.google_compute_network.existing[0].self_link
  subnetwork = local.subnetwork_self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel # RAPID | REGULAR | STABLE
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.private_cluster
    enable_private_endpoint = var.private_endpoint
    master_ipv4_cidr_block  = var.master_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = local.master_auth_cidrs
      content {
        cidr_block   = cidr_blocks.value
        display_name = "allowed"
      }
    }
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  lifecycle {
    ignore_changes = [node_pool]
  }

  depends_on = [google_project_service.container]
}

# Node pool (managed)
resource "google_container_node_pool" "default" {
  name     = "${var.cluster_name}-pool"
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  autoscaling {
    min_node_count = var.node_min
    max_node_count = var.node_max
  }

  node_config {
    machine_type = var.node_machine_type
    disk_type    = "pd-balanced"
    disk_size_gb = var.node_disk_gb
    preemptible  = var.node_preemptible
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = var.node_labels
    tags   = var.node_tags
  }
}

