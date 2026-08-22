# Azure Secure AKS Starter

Creates a small Azure foundation containing a resource group, VNet/subnet,
managed-identity AKS cluster, Log Analytics workspace, and zone-redundant
PostgreSQL Flexible Server. It is a starting point, not a complete production
platform.

## Resources

The current `main.tf` creates the resources listed above and an `appdb`
database. It does not create application workloads, Key Vault integration, or
network egress controls.

## Prerequisites

- Terraform and AzureRM provider access
- Azure CLI authenticated with `az login`
- Subscription permissions for resource groups, AKS, networking, monitoring,
  and PostgreSQL

## Configuration

Set `location`, `rg_name`, `vnet_cidr`, `subnet_cidr`, `aks_name`, `dns_prefix`,
node sizing, PostgreSQL settings, and sensitive `postgres_password`. The
default names are generic examples; override them for Azure name uniqueness.

## Deploy

```bash
az login
terraform init
terraform plan
terraform apply
```

Review the plan. AKS, PostgreSQL, and Log Analytics can incur charges.

## Destroy

```bash
terraform destroy
```

Back up any database data before destroying the starter.
