output "instance_id" { value = google_sql_database_instance.database.id }
output "connection_name" { value = google_sql_database_instance.database.connection_name }
output "ip_address" { value = try(google_sql_database_instance.database.first_ip_address, null) }
