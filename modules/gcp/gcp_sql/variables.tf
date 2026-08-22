variable "project_id" {
  type    = string
  default = null
}
variable "instance_name" {
  type    = string
  default = "crft-sql-instance"
}
variable "database_version" {
  type    = string
  default = "POSTGRES_15"
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "tier" {
  type    = string
  default = "e2-standard-8"
}
variable "disk_size_gb" {
  type    = number
  default = 20
}
variable "disk_type" {
  type    = string
  default = "PD_SSD"
}
variable "availability_type" {
  type    = string
  default = "ZONAL"
}
