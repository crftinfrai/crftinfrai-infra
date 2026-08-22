# Azure Container Instance

Creates a simple Azure Container Instance deployment.

## Resources

Randomized resource/container names, resource group, and Linux container group
with the configured image, port, CPU, memory, and restart policy.

## Requirements

Terraform >= 1.5, AzureRM, and Random providers declared in `versions.tf`.

## Usage

```hcl
module "aci" {
  source = "./modules/azure/azure_aci"
  image  = "nginx:latest"
  port   = 80
}
```

## Inputs

Location/name prefixes, `image`, `port`, `cpu_cores`, `memory_in_gb`, and
`restart_policy`.

## Outputs

`container_ipv4_address` and `container_group_id`.
