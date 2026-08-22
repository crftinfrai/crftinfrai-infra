# Azure Function App

Creates a Linux Azure Function App and its supporting resource group, storage,
and service plan.

## Resources

Resource group, storage account, Linux service plan, and Linux Function App.

## Requirements

Terraform >= 1.5 and the AzureRM provider declared in `versions.tf`.

## Usage

```hcl
module "function" {
  source             = "./modules/azure/azure_function"
  resource_group_name = "example-rg"
  location           = "eastus"
  function_app_name  = "example-function"
  storage_account_name = "examplefuncstore"
}
```

## Inputs

Resource names/location, `runtime_stack`, and the storage/service-plan names.

## Outputs

`function_app_id`, `function_app_name`, and `default_hostname`.
