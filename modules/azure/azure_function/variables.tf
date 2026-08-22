variable "resource_group_name" {
  type    = string
  default = "crft-function-rg"
}
variable "location" {
  type    = string
  default = "East US"
}
variable "function_app_name" {
  type    = string
  default = "crft-function-app"
}
variable "storage_account_name" {
  type    = string
  default = "crftfunctionstorage"
}
variable "service_plan_name" {
  type    = string
  default = "crft-function-plan"
}
variable "runtime_stack" {
  type    = string
  default = "node|20"
}