output "function_id" { value = google_cloudfunctions2_function.function.id }
output "function_name" { value = google_cloudfunctions2_function.function.name }
output "service_uri" { value = google_cloudfunctions2_function.function.service_config[0].uri }
