// filename: variables.tf

variable "project_id" { type = string }
variable "region" { type = string }
variable "location" { type = string } # region or zone (e.g., "asia-south1")

variable "enable_apis" {
  type    = bool
  default = true
}
# Network
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vpc_name" {
  type    = string
  default = "crft-gke-vpc"
}
variable "subnet_name" {
  type    = string
  default = "crft-gke-subnet"
}
variable "subnet_cidr" {
  type    = string
  default = "10.50.0.0/24"
}
# VPC-native ranges
variable "pods_range_name" {
  type    = string
  default = "pods"
}
variable "pods_cidr" {
  type    = string
  default = "10.52.0.0/14"
}
variable "services_range_name" {
  type    = string
  default = "services"
}
variable "services_cidr" {
  type    = string
  default = "10.56.0.0/20"
}
# Existing
variable "existing_vpc_name" {
  type    = string
  default = null
}
variable "existing_subnet_name" {
  type    = string
  default = null
}
variable "existing_pods_range_name" {
  type    = string
  default = null
}
variable "existing_services_range_name" {
  type    = string
  default = null
}
# Cluster
variable "cluster_name" {
  type    = string
  default = "crft-gke"
}
variable "release_channel" {
  type    = string
  default = "REGULAR"
}
variable "private_cluster" {
  type    = bool
  default = false
}
variable "private_endpoint" {
  type    = bool
  default = false
}
variable "master_cidr" {
  type    = string
  default = "172.16.0.0/28"
}
variable "master_authorized_cidrs" {
  type    = list(string)
  default = [] # e.g., ["YOUR.IP/32"]
}

# Node pool
variable "node_count" {
  type    = number
  default = 1
}
variable "node_min" {
  type    = number
  default = 1
}
variable "node_max" {
  type    = number
  default = 3
}
variable "node_machine_type" {
  type    = string
  default = "e2-standard-4"
}
variable "node_disk_gb" {
  type    = number
  default = 100
}
variable "node_preemptible" {
  type    = bool
  default = false
}
variable "node_labels" {
  type    = map(string)
  default = {}
}
variable "node_tags" {
  type    = list(string)
  default = []
}
