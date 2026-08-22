// filename: variables.tf

variable "project_id" { type = string }
variable "region" { type = string }
variable "zone" { type = string }

variable "name_prefix" {
  type    = string
  default = "web"
}
# Network mode: "create" | "existing"
variable "network_mode" {
  type    = string
  default = "create"
}
# When creating network/subnets
variable "vpc_name" {
  type    = string
  default = "web-vpc"
}
variable "subnets" {
  description = "Map of subnet_name => CIDR"
  type        = map(string)
  default     = { "web-subnet-1" = "10.10.0.0/24" }
}

# When using existing
variable "existing_vpc_name" {
  description = "Existing VPC name when network_mode=existing"
  type        = string
  default     = null
}
variable "existing_subnet_names" {
  description = "List of existing subnet names (region-scoped) if not using self_links"
  type        = list(string)
  default     = []
}
variable "existing_subnet_self_links" {
  description = "List of subnets by self_link (recommended)"
  type        = list(string)
  default     = []
}

# Firewalls
variable "enable_firewall_http_https" {
  type    = bool
  default = true
}
variable "enable_firewall_ssh" {
  type    = bool
  default = true
}
variable "enable_firewall_internal" {
  type    = bool
  default = true
}
# Sources
variable "web_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "admin_cidr" {
  description = "Single CIDR for SSH (optional). If not set, ssh_source_ranges or 0.0.0.0/0 is used."
  type        = string
  default     = null
}
variable "ssh_source_ranges" {
  description = "List of CIDRs allowed for SSH"
  type        = list(string)
  default     = []
}

# VM
variable "instance_name" {
  type    = string
  default = "web-prod-vm"
}
variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}
variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}
variable "image_project" {
  type    = string
  default = "ubuntu-os-cloud"
}
variable "boot_disk_size_gb" {
  type    = number
  default = 100
}
variable "boot_disk_type" {
  type    = string
  default = "pd-balanced"
}
variable "instance_tags" {
  type    = list(string)
  default = []
}
variable "labels" {
  type    = map(string)
  default = { env = "prod", app = "web" }
}
# Public/Private IP
variable "create_public_ip" {
  type    = bool
  default = true
}
variable "allocate_static_ip" {
  type    = bool
  default = true
}
# NAT (if create_public_ip=false but you still want egress)
variable "create_nat" {
  type    = bool
  default = false
}
# Service Account
variable "create_service_account" {
  type    = bool
  default = true
}
variable "service_account_email" {
  type    = string
  default = null
}
variable "service_account_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

# SSH users (metadata 'ssh-keys')
variable "ssh_users" {
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []
}

# Startup
variable "startup_script" {
  type    = string
  default = ""
}
variable "startup_script_path" {
  type    = string
  default = ""
}
# Metadata passthrough
variable "metadata" {
  type    = map(string)
  default = {}
}

# DNS (optional)
variable "create_dns_zone" {
  type    = bool
  default = false
}
variable "create_dns_record" {
  type    = bool
  default = false
}
variable "root_domain" {
  type    = string
  default = ""
}
variable "subdomain" {
  type    = string
  default = "app"
}
