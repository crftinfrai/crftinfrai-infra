# Azure Storage

Creates an Azure resource group and Storage Account.

## Resources

Resource group and Storage Account with configurable tier, replication, and
security settings.

## Requirements

Terraform >= 1.5 and the AzureRM provider declared in `versions.tf`.

## Usage

```hcl
module "storage" {
  source               = "./modules/azure/azure_storage"
  storage_account_name = "examplestorage123"
  resource_group_name  = "example-rg"
  location             = "eastus"
}
```

## Inputs

`storage_account_name`, `resource_group_name`, `location`, account tier, and
replication type.

## Outputs

`storage_account_id`, `storage_account_name`, and `primary_blob_endpoint`.
