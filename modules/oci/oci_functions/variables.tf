variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }
variable "compartment_ocid" { type = string }
variable "application_name" {
  type    = string
  default = "crft-function-app"
}
variable "function_name" {
  type    = string
  default = "crft-function"
}
variable "image" { type = string }
variable "memory_in_mbs" {
  type    = number
  default = 128
}
variable "timeout_in_seconds" {
  type    = number
  default = 30
}
variable "subnet_id" { type = string }
