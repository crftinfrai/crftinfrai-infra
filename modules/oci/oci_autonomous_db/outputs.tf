output "database_id" { value = oci_database_autonomous_database.database.id }
output "connection_strings" { value = try(oci_database_autonomous_database.database.connection_strings, null) }
