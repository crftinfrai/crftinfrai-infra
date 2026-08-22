resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_id
  name           = var.bucket_name
  namespace      = var.namespace
  storage_tier   = "Standard"
  access_type    = "NoPublicAccess"
}
