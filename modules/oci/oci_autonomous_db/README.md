# OCI Autonomous Database

Creates an OCI Autonomous Database in the selected compartment.

## Resources

One `oci_database_autonomous_database`.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "adb" {
  source         = "./modules/oci/oci_autonomous_db"
  tenancy_ocid   = var.tenancy_ocid
  user_ocid      = var.user_ocid
  fingerprint    = var.fingerprint
  private_key_path = var.private_key_path
  region         = var.region
  compartment_id = var.compartment_id
  db_name        = "exampleadb"
  admin_password = var.admin_password
}
```

## Inputs

OCI authentication values, region, compartment, database name, password,
workload, CPU, and storage settings.

## Outputs

`database_id` and `connection_strings`.

## Notes

Supply OCI key material and passwords through protected local configuration.
