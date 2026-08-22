// filename: main.tf

############################
# Locals
############################
locals {
  create_net       = var.network_mode == "create"
  use_existing_net = var.network_mode == "existing"

  # ssh ranges: prefer explicit list; else admin_cidr; else open (you can override)
  ssh_ranges = (
    length(var.ssh_source_ranges) > 0
    ? var.ssh_source_ranges
    : (var.admin_cidr != null && var.admin_cidr != "" ? [var.admin_cidr] : ["0.0.0.0/0"])
  )

  # Build ssh-keys metadata from list of users (username:key)
  ssh_keys = join("\n", [for u in var.ssh_users : "${u.username}:${u.public_key}"])

  # Startup script (inline beats file, else empty)
  startup_script = (
    var.startup_script != "" ? var.startup_script :
    (var.startup_script_path != "" ? file(var.startup_script_path) : "")
  )
}

############################
# Network (create)
############################
resource "google_compute_network" "vpc" {
  count                   = local.create_net ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# multiple subnets: name => cidr
resource "google_compute_subnetwork" "subnet" {
  for_each      = local.create_net ? var.subnets : {}
  name          = each.key
  region        = var.region
  network       = google_compute_network.vpc[0].id
  ip_cidr_range = each.value
}

############################
# Network (existing)
############################
data "google_compute_network" "existing" {
  count = local.use_existing_net ? 1 : 0
  name  = var.existing_vpc_name
}

# Prefer self_links if provided; else resolve by (name, region)
data "google_compute_subnetwork" "existing_by_link" {
  for_each  = local.use_existing_net && length(var.existing_subnet_self_links) > 0 ? toset(var.existing_subnet_self_links) : toset([])
  self_link = each.value
}

data "google_compute_subnetwork" "existing_by_name" {
  for_each = local.use_existing_net && length(var.existing_subnet_self_links) == 0 ? toset(var.existing_subnet_names) : toset([])
  name     = each.value
  region   = var.region
  project  = var.project_id
}

############################
# Chosen network & subnets
############################
locals {
  network_id = local.create_net ? google_compute_network.vpc[0].id : data.google_compute_network.existing[0].id

  # consolidate subnets from either creation or data sources
  created_subnet_ids = [for s in google_compute_subnetwork.subnet : s.id]
  existing_subnet_ids = concat(
    [for s in data.google_compute_subnetwork.existing_by_link : s.id],
    [for s in data.google_compute_subnetwork.existing_by_name : s.id]
  )
  all_subnet_ids = local.create_net ? local.created_subnet_ids : local.existing_subnet_ids

  # CIDRs (primary + secondary) for internal firewall
  created_subnet_cidrs = flatten([
    for s in google_compute_subnetwork.subnet : concat(
      [s.ip_cidr_range],
      try([for r in s.secondary_ip_range : r.ip_cidr_range], [])
    )
  ])
  existing_subnet_cidrs = flatten([
    for s in concat(values(data.google_compute_subnetwork.existing_by_link), values(data.google_compute_subnetwork.existing_by_name)) : concat(
      [s.ip_cidr_range],
      try([for r in s.secondary_ip_range : r.ip_cidr_range], [])
    )
  ])
  all_internal_cidrs = local.create_net ? local.created_subnet_cidrs : local.existing_subnet_cidrs
}

############################
# Static external IP (optional)
############################
resource "google_compute_address" "static" {
  count  = (var.create_public_ip && var.allocate_static_ip) ? 1 : 0
  name   = "${var.name_prefix}-ip"
  region = var.region
}

############################
# Firewall
############################
# HTTP
resource "google_compute_firewall" "allow_http" {
  count   = var.enable_firewall_http_https ? 1 : 0
  name    = "${var.name_prefix}-allow-http"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.web_source_ranges
  target_tags   = ["http-server"]
}

# HTTPS
resource "google_compute_firewall" "allow_https" {
  count   = var.enable_firewall_http_https ? 1 : 0
  name    = "${var.name_prefix}-allow-https"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = var.web_source_ranges
  target_tags   = ["https-server"]
}

# SSH
resource "google_compute_firewall" "allow_ssh" {
  count   = var.enable_firewall_ssh ? 1 : 0
  name    = "${var.name_prefix}-allow-ssh"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = local.ssh_ranges
  target_tags   = ["${var.name_prefix}-ssh"]
}

# Internal (use subnets’ CIDRs)
resource "google_compute_firewall" "allow_internal" {
  count   = var.enable_firewall_internal ? 1 : 0
  name    = "${var.name_prefix}-allow-internal"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = local.all_internal_cidrs
}

############################
# Cloud Router + NAT (for private VM egress)
############################
resource "google_compute_router" "router" {
  count   = var.create_nat ? 1 : 0
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = local.network_id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.create_nat ? 1 : 0
  name                               = "${var.name_prefix}-nat"
  region                             = var.region
  router                             = google_compute_router.router[0].name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

############################
# Service Account (optional)
############################
resource "google_service_account" "vm_sa" {
  count        = var.create_service_account ? 1 : 0
  account_id   = "${var.name_prefix}-sa"
  display_name = "${var.name_prefix} VM Service Account"
}

locals {
  service_account_email = var.create_service_account ? google_service_account.vm_sa[0].email : var.service_account_email
}

############################
# Instance
############################
resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = "e2-standard-4"
  zone         = var.zone

  tags = concat(
    var.instance_tags,
    var.enable_firewall_http_https ? ["http-server", "https-server"] : [],
    var.enable_firewall_ssh ? ["${var.name_prefix}-ssh"] : []
  )

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    # pick the first subnet for primary NIC
    subnetwork = element(local.all_subnet_ids, 0)

    dynamic "access_config" {
      for_each = var.create_public_ip ? [1] : []
      content {
        nat_ip = var.allocate_static_ip ? try(google_compute_address.static[0].address, null) : null
      }
    }
  }

  service_account {
    email  = local.service_account_email
    scopes = var.service_account_scopes
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = merge(
    var.metadata,
    {
      "ssh-keys"       = local.ssh_keys
      "startup-script" = local.startup_script
    }
  )

  labels = var.labels

  allow_stopping_for_update = true

  depends_on = [
    google_compute_firewall.allow_http,
    google_compute_firewall.allow_https,
    google_compute_firewall.allow_ssh
  ]
}

############################
# Cloud DNS (optional)
############################
resource "google_dns_managed_zone" "zone" {
  count       = var.create_dns_zone ? 1 : 0
  name        = "${var.name_prefix}-zone"
  dns_name    = "${var.root_domain}."
  description = "${var.name_prefix} managed zone"
}

resource "google_dns_record_set" "a_record" {
  count        = var.create_dns_record ? 1 : 0
  name         = "${var.subdomain}.${var.root_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.zone[0].name
  rrdatas = [coalesce(
    try(google_compute_address.static[0].address, null),
    try(google_compute_instance.vm.network_interface[0].access_config[0].nat_ip, null)
  )]
}
