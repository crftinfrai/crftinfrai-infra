variable "storage_account_name" {
  type        = string
  description = "Globally unique Azure Storage account name."
  default     = "crftstorage"
}

variable "resource_group_name" {
  type    = string
  default = "crft-storage-rg"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}
