variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }
variable "compartment_id" { type = string }
variable "namespace" { type = string }
variable "bucket_name" {
  type    = string
  default = "crft-object-bucket"
}