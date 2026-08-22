# OCI PostgreSQL database

Creates an OCI PostgreSQL database system in an existing subnet.

## Resources

One `oci_psql_db_system`.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "db" {
  source         = "./modules/oci/oci_db"
  tenancy_ocid   = var.tenancy_ocid
  user_ocid      = var.user_ocid
  fingerprint    = var.fingerprint
  private_key_path = var.private_key_path
  region         = var.region
  compartment_id = var.compartment_id
  subnet_id      = var.subnet_id
  db_system_credentials_password_details_password = var.database_password
  db_system_display_name = "example-db"
}
```

## Inputs

OCI authentication, region/compartment/subnet, database version, shape,
storage, credentials, instance count, memory, and OCPU settings.

## Outputs

`db_system_id` and `db_system_display_name`.
