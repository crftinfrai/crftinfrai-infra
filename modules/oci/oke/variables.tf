// filename: variables.tf

variable "compartment_ocid" { type = string }
variable "availability_domain" { type = string }
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }
variable "name_prefix" {
  type    = string
  default = "crft"
}
# Network
variable "network_mode" {
  type    = string
  default = "create"
}
variable "vcn_cidr" {
  type    = string
  default = "10.80.0.0/16"
}
variable "node_subnet_cidr" {
  type    = string
  default = "10.80.1.0/24"
}
variable "lb_subnet_cidr" {
  type    = string
  default = "10.80.2.0/24"
}
variable "existing_vcn_id" {
  type    = string
  default = null
}
variable "existing_node_subnet_id" {
  type    = string
  default = null
}
variable "existing_lb_subnet_id" {
  type    = string
  default = null
}
# Cluster
variable "cluster_name" {
  type    = string
  default = "crft-oke"
}
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "api_public" {
  type    = bool
  default = true
}
# Node pool
variable "node_count" {
  type    = number
  default = 2
}
variable "node_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "node_ocpus" {
  type    = number
  default = 2
}
variable "node_memory_gbs" {
  type    = number
  default = 8
}
variable "node_image_ocid" { type = string } # supply marketplace image ocid (Oracle Linux/Ubuntu)
variable "assign_public_ip" {
  type    = bool
  default = true
}
