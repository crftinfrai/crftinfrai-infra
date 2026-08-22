# Azure AKS

Creates an AKS cluster with configurable networking, identity, RBAC, and
node-pool settings.

## Resources

Resource group, VNet/subnet when creating a network, and AKS cluster with
managed identity and configurable private/public API access.

## Requirements

Terraform >= 1.5 and the AzureRM provider declared in `versions.tf`.

## Usage

```hcl
module "aks" {
  source       = "./modules/azure/azure_aks"
  resource_group_name = "example-rg"
  location     = "eastus"
  cluster_name = "example-aks"
}
```

## Inputs

Use `resource_group_name`, `location`, `network_mode`, VNet/subnet settings,
`cluster_name`, Kubernetes version, API access, and node sizing inputs.

## Outputs

`cluster_name`, `fqdn`, `private_fqdn`, and `kube_admin_config`.

## Notes

Treat `kube_admin_config` as sensitive connection material.
