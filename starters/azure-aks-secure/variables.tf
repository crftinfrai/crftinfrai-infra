variable "location" {
  type    = string
  default = "Central India"
}
variable "rg_name" {
  type    = string
  default = "rg-example"
}
variable "vnet_cidr" {
  type    = string
  default = "10.30.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.30.1.0/24"
}
variable "aks_name" {
  type    = string
  default = "example-aks"
}
variable "dns_prefix" {
  type    = string
  default = "example-aks"
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "node_vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}
variable "postgres_sku_name" {
  type    = string
  default = "GP_Standard_D2s_v3"
}
variable "postgres_version" {
  type    = string
  default = "14"
}
variable "postgres_admin" {
  type    = string
  default = "appuser"
}
variable "postgres_password" {
  type      = string
  default   = null
  sensitive = true
}
