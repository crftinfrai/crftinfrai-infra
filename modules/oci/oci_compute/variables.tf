// filename: variables.tf

variable "compartment_ocid" { type = string }
variable "availability_domain" { type = string } # e.g., "kIdk:AP-MUMBAI-1-AD-1"
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }

variable "name_prefix" {
  type    = string
  default = "web"
}
# Network
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vcn_cidr" {
  type    = string
  default = "10.40.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.40.1.0/24"
}
variable "existing_subnet_id" {
  type    = string
  default = null
}
# VM
variable "instance_name" {
  type    = string
  default = "web-oci-vm"
}
variable "shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "shape_ocpus" {
  type    = number
  default = 2
}
variable "shape_memory_gbs" {
  type    = number
  default = 8
}
variable "boot_volume_size_gb" {
  type    = number
  default = 50
}
# Image
variable "image_ocid" {
  type    = string
  default = null
}

# Public IP
variable "assign_public_ip" {
  type    = bool
  default = true
}
variable "allocate_reserved_ip" {
  type    = bool
  default = true
}
# SSH users (collect keys)
variable "ssh_users" {
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []
}

# cloud-init/user_data
variable "user_data" {
  type    = string
  default = ""
}
variable "user_data_path" {
  type    = string
  default = ""
}
# DNS
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
variable "existing_zone_id" {
  type    = string
  default = null
}
# Tags (not all OCI resources use tags; included where supported)
variable "freeform_tags" {
  type    = map(string)
  default = { env = "prod", app = "web" }
}
