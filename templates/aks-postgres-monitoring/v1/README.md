# AKS + PostgreSQL + Monitoring — Azure

This deterministic, single-file Terraform template creates an Azure resource group, a private virtual network, an Azure Kubernetes Service cluster, a private PostgreSQL Flexible Server, and Azure Monitor container monitoring through Log Analytics.

## Architecture

```text
Resource Group
└── Virtual Network
    ├── AKS subnet
    │   └── AKS cluster and system node pool
    └── Delegated PostgreSQL subnet
        └── PostgreSQL Flexible Server

Private DNS zone: private.postgres.database.azure.com
Log Analytics workspace ← AKS OMS/container monitoring
```

The PostgreSQL subnet is delegated to `Microsoft.DBforPostgreSQL/flexibleServers`. The private DNS zone is linked to the virtual network so workloads in the VNet can resolve the private server name. PostgreSQL public network access is disabled.

## Resources created

- Azure resource group
- Virtual network with separate AKS and delegated PostgreSQL subnets
- Private DNS zone and virtual network link for PostgreSQL Flexible Server
- User-assigned managed identity and subnet-scoped Network Contributor role assignment for AKS networking
- AKS cluster with Azure CNI, Azure network policy, Kubernetes RBAC, OIDC issuer, workload identity, and an autoscaling system node pool
- PostgreSQL Flexible Server and an initial database
- Log Analytics workspace with AKS OMS/container monitoring integration

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI and `kubectl`
- An Azure subscription and permissions to create the listed resources and the subnet-scoped role assignment
- Network access to Azure from the machine running Terraform

Authenticate using normal Azure Terraform mechanisms. For example:

```bash
az login
az account set --subscription "<subscription-id>"
```

The AzureRM provider uses the active Azure CLI session or supported environment/managed-identity authentication. No subscription, tenant, client ID, or client secret is stored in this template.

## Configuration

All variables are defined in `main.tf` and have defaults. Important inputs include:

- `location`, `resource_group_name`, and `name_prefix`
- `vnet_cidr`, `aks_subnet_cidr`, and `database_subnet_cidr`
- `aks_cluster_name`, `kubernetes_version`, `aks_node_vm_size`, `aks_node_min_count`, `aks_node_max_count`, and `aks_os_disk_size_gb`
- `postgres_server_name`, `postgres_version`, `postgres_sku_name`, `postgres_storage_mb`, and `postgres_database_name`
- `log_analytics_workspace_name` and `log_retention_days`

The PostgreSQL server name must be globally unique in Azure. The subnet CIDRs must be non-overlapping and contained within `vnet_cidr`.

## Database credentials

`postgres_admin_password` is sensitive and defaults to `null`; provide it through a protected variable or secret-injection workflow. Do not commit it to source control.

```bash
export TF_VAR_postgres_admin_password='<password-from-your-secret-store>'
```

The password is not exposed in outputs. Terraform state can still contain credentials, so use an encrypted, access-controlled remote state backend for shared environments.

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. AKS, PostgreSQL Flexible Server, and Log Analytics incur Azure charges.

## Connect to AKS

After applying, retrieve credentials using Azure CLI:

```bash
az aks get-credentials \
  --resource-group "<resource-group-name>" \
  --name "<aks-cluster-name>"

kubectl get nodes
```

Use the `resource_group_name` and `aks_cluster_name` Terraform outputs for the command values.

## Monitoring

The template creates a `PerGB2018` Log Analytics workspace and enables the AKS `oms_agent` integration against that workspace. This provides Azure Monitor container telemetry for the cluster and workloads supported by the AKS monitoring agent.

Inspect workspace data and container insights in the Azure portal under the Log Analytics workspace or the AKS monitoring blade. The template does not create Managed Grafana, managed Prometheus, Application Insights, or custom diagnostic settings.

## PostgreSQL

PostgreSQL Flexible Server is deployed into the delegated private subnet with the Azure-supported private DNS zone `private.postgres.database.azure.com`. Its public network access is disabled. Applications must run in a network location with access to the VNet and use the server FQDN from the `postgres_server_fqdn` output.

## Destroy

```bash
terraform destroy
```

Review the destruction plan carefully. Take any required PostgreSQL backup before destroying the server. The configuration does not enable PostgreSQL high availability or an external backup vault; retain data according to your organization’s policy before destruction.

## Security notes

- AKS uses a user-assigned managed identity; no service principal secret is required.
- The identity receives Network Contributor only on the AKS subnet.
- PostgreSQL uses private networking, a delegated subnet, and private DNS.
- PostgreSQL public network access and public firewall rules are not configured.
- The administrator password is sensitive, is not hardcoded, and is never output.
- Protect Terraform state because sensitive provider-managed values can be recorded there.

## Production considerations

Review Azure region support and SKU availability for the selected Kubernetes and PostgreSQL versions. Consider PostgreSQL zone-redundant high availability, a tested backup/restore process, Azure Key Vault-backed secret rotation, Azure Policy, workload identity permissions, private AKS API networking, controlled egress/NAT design, and centralized security logging before using this as a production deployment. These items are not all created by this template.

## Cost warning

AKS, PostgreSQL Flexible Server, networking, and Log Analytics are billable
Azure services. Review the selected SKUs and retention before applying.
