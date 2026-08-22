# Cloud SQL

Creates a Google Cloud SQL database instance.

## Resources

One `google_sql_database_instance` with configurable version, tier, storage,
availability, and project/region.

## Requirements

Terraform >= 1.5 and the Google provider declared in `versions.tf`.

## Usage

```hcl
module "sql" {
  source        = "./modules/gcp/gcp_sql"
  project_id    = var.project_id
  instance_name = "example-sql"
}
```

## Inputs

`project_id`, `instance_name`, database version, region, tier, disk, and
availability settings.

## Outputs

`instance_id`, `connection_name`, and `ip_address`.
