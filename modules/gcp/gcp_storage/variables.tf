variable "project_id" {
  type    = string
  default = null
}
variable "bucket_name" {
  type    = string
  default = "crft-storage-bucket"
}
variable "location" {
  type    = string
  default = "US"
}
variable "storage_class" {
  type    = string
  default = "STANDARD"
}
variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}