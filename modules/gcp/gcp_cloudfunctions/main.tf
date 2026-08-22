resource "google_storage_bucket" "function_source" {
  project                     = var.project_id
  name                        = var.source_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
}

# The source archive is intentionally external: upload var.source_object to this bucket before apply.
resource "google_cloudfunctions2_function" "function" {
  project  = var.project_id
  name     = var.function_name
  location = var.region

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = var.source_object
      }
    }
  }

  service_config {
    available_memory = var.memory
    timeout_seconds  = var.timeout_seconds
    ingress_settings = "ALLOW_ALL"
  }
}
