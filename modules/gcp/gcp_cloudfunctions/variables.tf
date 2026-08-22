variable "project_id" {
  type    = string
  default = null
}
variable "function_name" {
  type    = string
  default = "crft-function"
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "runtime" {
  type    = string
  default = "nodejs20"
}
variable "entry_point" {
  type    = string
  default = "helloWorld"
}
variable "source_bucket_name" {
  type    = string
  default = "crft-function-source"
}
variable "source_object" {
  type    = string
  default = "source.zip"
}
variable "memory" {
  type    = string
  default = "512Mi"
}
variable "timeout_seconds" {
  type    = number
  default = 60
}