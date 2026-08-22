resource "google_sql_database_instance" "database" {
  project          = var.project_id
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region

  settings {
    tier              = var.tier
    disk_size         = var.disk_size_gb
    disk_type         = var.disk_type
    availability_type = var.availability_type
  }
}
