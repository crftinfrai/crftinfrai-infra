resource "oci_functions_application" "application" {
  compartment_id = var.compartment_ocid
  display_name   = var.application_name
  subnet_ids     = [var.subnet_id]
}

resource "oci_functions_function" "function" {
  application_id     = oci_functions_application.application.id
  display_name       = var.function_name
  image              = var.image
  memory_in_mbs      = var.memory_in_mbs
  timeout_in_seconds = var.timeout_in_seconds
}
