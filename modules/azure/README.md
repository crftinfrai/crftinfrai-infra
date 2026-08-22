# Azure modules

Reusable Azure Terraform modules:

- `azure_aci` — Azure Container Instances deployment.
- `azure_aks` — AKS cluster foundation.
- `azure_function` — Function App and supporting storage/service plan.
- `azure_sql` — PostgreSQL Flexible Server and database.
- `azure_storage` — resource group and Storage Account.
- `azure_vm` — Linux VM, networking, security rules, and optional DNS.

Provider versions and authentication requirements are declared in each module.
Use Azure CLI, managed identity, or another supported external authentication
method rather than storing subscription or client credentials in Terraform.
