variable "resource_group_location" {
  type    = string
  default = "eastus"
}
variable "resource_group_name_prefix" {
  type    = string
  default = "crft-aci-rg"
}
variable "container_group_name_prefix" {
  type    = string
  default = "crft-aci"
}
variable "container_name_prefix" {
  type    = string
  default = "app"
}
variable "image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/aci-helloworld"
}
variable "port" {
  type    = number
  default = 80
}
variable "cpu_cores" {
  type    = number
  default = 1
}
variable "memory_in_gb" {
  type    = number
  default = 2
}
variable "restart_policy" {
  type    = string
  default = "Always"
}