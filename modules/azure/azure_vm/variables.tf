// filename: variables.tf

variable "resource_group_name" { type = string }
variable "location" {
  type    = string
  default = "Central India"
}
variable "name_prefix" {
  type    = string
  default = "web"
}
# Network mode
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vnet_name" {
  type    = string
  default = "web-vnet"
}
variable "vnet_cidr" {
  type    = string
  default = "10.30.0.0/16"
}
variable "subnet_name" {
  type    = string
  default = "web-subnet"
}
variable "subnet_cidr" {
  type    = string
  default = "10.30.1.0/24"
}
variable "existing_subnet_id" {
  type    = string
  default = null
}
# Security
variable "ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
# VM
variable "vm_name" {
  type    = string
  default = "web-az-vm"
}
variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "ssh_public_key" { type = string }

variable "os_disk_size_gb" {
  type    = number
  default = 64
}
variable "os_disk_type" {
  type    = string
  default = "Premium_LRS"
}
# Ubuntu 22.04
variable "image_publisher" {
  type    = string
  default = "Canonical"
}
variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}
variable "image_sku" {
  type    = string
  default = "22_04-lts-gen2"
}
# Public IP
variable "create_public_ip" {
  type    = bool
  default = true
}
# cloud-init/custom_data
variable "custom_data" {
  type    = string
  default = ""
}
variable "custom_data_path" {
  type    = string
  default = ""
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
variable "existing_zone_name" {
  type    = string
  default = null
}
# Tags
variable "tags" {
  type    = map(string)
  default = { env = "prod", app = "web" }
}
