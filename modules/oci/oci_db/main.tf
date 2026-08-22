resource "oci_psql_db_system" "test_db_system" {
  #Required
  compartment_id = var.compartment_id
  db_version     = var.db_system_db_version
  display_name   = var.db_system_display_name
  network_details {
    #Required
    subnet_id = var.subnet_id
  }
  shape = var.db_system_shape
  storage_details {
    #Required
    is_regionally_durable = var.db_system_storage_details_is_regionally_durable
    system_type           = var.db_system_storage_details_system_type
    #Optional
  }
  credentials {
    #Required
    password_details {
      #Required
      password_type = var.db_system_credentials_password_details_password_type
      #Optional
      password = var.db_system_credentials_password_details_password
    }
    username = var.db_system_credentials_username
  }
  instance_count              = var.db_system_instance_count
  instance_memory_size_in_gbs = var.db_system_instance_memory_size_in_gbs
  instance_ocpu_count         = var.db_system_instance_ocpu_count

}


