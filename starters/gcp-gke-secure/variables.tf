variable "project_id" {
  type        = string
  description = "GCP project ID"
}
variable "region" {
  type    = string
  default = "asia-south1"
}
variable "zone" {
  type    = string
  default = "asia-south1-a"
}
variable "network_name" {
  type    = string
  default = "gke-vpc"
}
variable "subnet_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "cluster_name" {
  type    = string
  default = "example-gke"
}
variable "release_channel" {
  type    = string
  default = "REGULAR"
}
variable "enable_private_nodes" {
  type    = bool
  default = true
}
variable "master_cidr" {
  type    = string
  default = "172.16.0.0/28"
}
variable "db_tier" {
  type    = string
  default = "db-custom-2-7680"
}
variable "db_version" {
  type    = string
  default = "POSTGRES_14"
}
variable "database_name" {
  type    = string
  default = "appdb"
}
variable "database_user" {
  type    = string
  default = "appuser"
}
variable "database_password" {
  type      = string
  default   = null
  sensitive = true
}
variable "labels" {
  type    = map(string)
  default = { environment = "example", managed_by = "terraform" }
}
