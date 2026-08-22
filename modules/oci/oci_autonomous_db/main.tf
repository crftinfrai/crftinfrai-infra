resource "oci_database_autonomous_database" "database" {
  compartment_id           = var.compartment_id
  db_name                  = var.db_name
  cpu_core_count           = var.cpu_core_count
  data_storage_size_in_tbs = var.data_storage_size_in_tbs
  admin_password           = var.admin_password
  db_workload              = var.db_workload
}
