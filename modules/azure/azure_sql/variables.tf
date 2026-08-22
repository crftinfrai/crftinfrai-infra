variable "resource_group_name" {
  type    = string
  default = "crft-postgres-rg"
}
variable "location" {
  type    = string
  default = "East US"
}
variable "server_name" {
  type    = string
  default = "crft-postgres-server"
}
variable "administrator_login" {
  type    = string
  default = "pgadmin"
}
variable "administrator_password" {
  type      = string
  sensitive = true
}
variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "postgresql_version" {
  type    = string
  default = "15"
}
variable "storage_mb" {
  type    = number
  default = 32768
}