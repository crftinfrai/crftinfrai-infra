# RDS database

Creates a configurable Amazon RDS database instance.

## Resources

One `aws_db_instance`; the module uses the provider's default networking
behavior and does not create a VPC.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "database" {
  source     = "./modules/aws/rds_database"
  identifier = "example-db"
  username   = "appuser"
  password   = var.database_password
}
```

## Inputs

Important inputs include `aws_region`, `identifier`, `engine`, `engine_version`,
`instance_class`, `allocated_storage`, `db_name`, `username`, `password`, and
`multi_az`.

## Outputs

`db_instance_id`, `endpoint`, and `address`.

## Notes

Pass the sensitive password through a protected variable or secret manager.
