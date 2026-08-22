# Azure PostgreSQL

Creates an Azure Database for PostgreSQL Flexible Server and its database.

## Resources

Resource group, PostgreSQL Flexible Server, and PostgreSQL database.

## Requirements

Terraform >= 1.5 and the AzureRM provider declared in `versions.tf`.

## Usage

```hcl
module "postgres" {
  source              = "./modules/azure/azure_sql"
  resource_group_name = "example-rg"
  location            = "eastus"
  server_name         = "example-postgres"
  administrator_password = var.database_password
}
```

## Inputs

Resource location/names, administrator credentials, PostgreSQL version, SKU,
and storage settings.

## Outputs

`server_id` and `fully_qualified_domain_name`.

## Notes

Supply the administrator password through protected variable injection.
