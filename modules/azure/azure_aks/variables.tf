// filename: variables.tf

variable "resource_group_name" { type = string }
variable "location" {
  type    = string
  default = "Central India"
}
variable "tags" {
  type    = map(string)
  default = { env = "prod", app = "crft" }
}
# Network
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vnet_name" {
  type    = string
  default = "crft-aks-vnet"
}
variable "vnet_cidr" {
  type    = string
  default = "10.70.0.0/16"
}
variable "subnet_name" {
  type    = string
  default = "crft-aks-subnet"
}
variable "subnet_cidr" {
  type    = string
  default = "10.70.1.0/24"
}
variable "existing_subnet_id" {
  type    = string
  default = null
}
# Cluster
variable "cluster_name" {
  type    = string
  default = "crft-aks"
}
variable "dns_prefix" {
  type    = string
  default = "crft"
}
variable "kubernetes_version" {
  type    = string
  default = null
}
# API access
variable "private_cluster" {
  type    = bool
  default = false
}
variable "api_authorized_ip_ranges" {
  type    = list(string)
  default = []
}
# Node pool
variable "node_vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}
variable "node_count" {
  type    = number
  default = 2
}
variable "node_min" {
  type    = number
  default = 1
}
variable "node_max" {
  type    = number
  default = 4
}
variable "node_disk_gb" {
  type    = number
  default = 100
}
# Network profile
variable "network_plugin" {
  type    = string
  default = "azure"
}
variable "network_policy" {
  type    = string
  default = "azure"
}
variable "service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}
variable "docker_bridge_cidr" {
  type        = string
  default     = "172.17.0.1/16"
  description = "Legacy compatibility input. AzureRM v5 removed docker_bridge_cidr from the AKS API and this value is no longer sent to Azure."
}
