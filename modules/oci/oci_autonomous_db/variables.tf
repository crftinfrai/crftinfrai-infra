variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }
variable "compartment_id" { type = string }
variable "db_name" {
  type    = string
  default = "CRFTDB"
}
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "cpu_core_count" {
  type    = number
  default = 2
}
variable "data_storage_size_in_tbs" {
  type    = number
  default = 1
}
variable "db_workload" {
  type    = string
  default = "OLTP"
}