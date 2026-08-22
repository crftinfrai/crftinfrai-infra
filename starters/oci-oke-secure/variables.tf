variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID"
}
variable "region" {
  type    = string
  default = "ap-hyderabad-1"
}
variable "vcn_cidr" {
  type    = string
  default = "10.40.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.40.1.0/24"
}
variable "oke_name" {
  type    = string
  default = "example-oke"
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
