variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }
variable "compartment_id" { type = string }
variable "subnet_id" { type = string }
variable "db_system_db_version" {
  type    = string
  default = "16"
}
variable "db_system_display_name" {
  type    = string
  default = "crft-postgres"
}
variable "db_system_shape" {
  type    = string
  default = "PostgreSQL.VM.Standard.E4.Flex"
}
variable "db_system_storage_details_is_regionally_durable" {
  type    = bool
  default = true
}
variable "db_system_storage_details_system_type" {
  type    = string
  default = "OCI_STANDARD"
}
variable "db_system_credentials_password_details_password_type" {
  type    = string
  default = "PLAIN_TEXT"
}
variable "db_system_credentials_password_details_password" {
  type      = string
  sensitive = true
}
variable "db_system_credentials_username" {
  type    = string
  default = "admin"
}
variable "db_system_instance_count" {
  type    = number
  default = 1
}
variable "db_system_instance_memory_size_in_gbs" {
  type    = number
  default = 8
}
variable "db_system_instance_ocpu_count" {
  type    = number
  default = 2
}