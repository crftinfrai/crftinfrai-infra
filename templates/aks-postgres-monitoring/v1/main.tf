terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group containing the deployment."
  type        = string
  default     = "crft-aks-postgres-rg"
}

variable "name_prefix" {
  description = "Prefix used for Azure resource names."
  type        = string
  default     = "crft-aks"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.name_prefix))
    error_message = "name_prefix must be 2-20 characters using lowercase letters, numbers, or hyphens."
  }
}

variable "vnet_cidr" {
  description = "Address space for the virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.20.0.0/20"
}

variable "database_subnet_cidr" {
  description = "Address prefix for the delegated PostgreSQL Flexible Server subnet."
  type        = string
  default     = "10.20.16.0/24"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "crft-aks-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS. Leave null to use the Azure-supported default."
  type        = string
  default     = null
}

variable "aks_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "aks_node_count" {
  description = "Initial system node count used when autoscaling is disabled by Azure during creation."
  type        = number
  default     = 2

  validation {
    condition     = var.aks_node_count >= 2
    error_message = "aks_node_count must be at least 2 for this production-oriented template."
  }
}

variable "aks_node_min_count" {
  description = "Minimum size of the AKS system node pool autoscaler."
  type        = number
  default     = 2

  validation {
    condition     = var.aks_node_min_count >= 2
    error_message = "aks_node_min_count must be at least 2."
  }
}

variable "aks_node_max_count" {
  description = "Maximum size of the AKS system node pool autoscaler."
  type        = number
  default     = 4

  validation {
    condition     = var.aks_node_max_count >= var.aks_node_min_count
    error_message = "aks_node_max_count must be greater than or equal to aks_node_min_count."
  }
}

variable "aks_os_disk_size_gb" {
  description = "OS disk size in GiB for AKS system nodes."
  type        = number
  default     = 128

  validation {
    condition     = var.aks_os_disk_size_gb >= 30
    error_message = "aks_os_disk_size_gb must be at least 30 GiB."
  }
}

variable "postgres_server_name" {
  description = "Globally unique Azure name for the PostgreSQL Flexible Server."
  type        = string
  default     = "crft-postgres-prod"
}

variable "postgres_version" {
  description = "Major PostgreSQL version for the Flexible Server."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "SKU for PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D2s_v5"
}

variable "postgres_storage_mb" {
  description = "Allocated PostgreSQL storage in MB."
  type        = number
  default     = 32768

  validation {
    condition     = var.postgres_storage_mb >= 32768
    error_message = "postgres_storage_mb must be at least 32768 MB."
  }
}

variable "postgres_database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "postgres_admin_username" {
  description = "Administrator username for PostgreSQL Flexible Server."
  type        = string
  default     = "appadmin"
}

variable "postgres_admin_password" {
  description = "Administrator password for PostgreSQL. Supply through a protected variable or TF_VAR_postgres_admin_password."
  type        = string
  sensitive   = true
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
  default     = "crft-aks-logs"
}

variable "log_retention_days" {
  description = "Log Analytics retention period in days."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730 days."
  }
}

# --------------------------------------------------
# Resource group and common tags
# --------------------------------------------------

locals {
  common_tags = {
    ManagedBy = "Terraform"
    Name      = var.name_prefix
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# --------------------------------------------------
# Virtual network and private subnets
# --------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr]
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "${var.name_prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "database" {
  name                 = "${var.name_prefix}-postgres-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.database_subnet_cidr]

  delegation {
    name = "postgres-flexible-server"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                 = "${var.name_prefix}-postgres-dns-link"
  private_dns_zone_id  = azurerm_private_dns_zone.postgres.id
  virtual_network_id   = azurerm_virtual_network.main.id
  registration_enabled = false
  tags                 = local.common_tags
}

# --------------------------------------------------
# AKS managed identity and networking permission
# --------------------------------------------------

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.name_prefix}-aks-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "aks_subnet_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# --------------------------------------------------
# Log Analytics and AKS
# --------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.name_prefix}-dns"
  kubernetes_version  = var.kubernetes_version

  node_provisioning_profile {
    mode = "Manual"
  }

  default_node_pool {
    name                        = "system"
    vm_size                     = var.aks_node_vm_size
    vnet_subnet_id              = azurerm_subnet.aks.id
    os_disk_size_gb             = var.aks_os_disk_size_gb
    type                        = "VirtualMachineScaleSets"
    min_count                   = var.aks_node_min_count
    max_count                   = var.aks_node_max_count
    node_count                  = var.aks_node_count
    temporary_name_for_rotation = "sysrotate"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  role_based_access_control_enabled = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  tags = local.common_tags

  depends_on = [azurerm_role_assignment.aks_subnet_network_contributor]
}

# --------------------------------------------------
# PostgreSQL Flexible Server
# --------------------------------------------------

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = var.postgres_server_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = var.postgres_version
  administrator_login           = var.postgres_admin_username
  administrator_password        = var.postgres_admin_password
  sku_name                      = var.postgres_sku_name
  storage_mb                    = var.postgres_storage_mb
  backup_retention_days         = 7
  delegated_subnet_id           = azurerm_subnet.database.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  tags = local.common_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "resource_group_name" {
  description = "Resource group containing the deployment."
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region containing the deployment."
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.main.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "AKS cluster resource ID."
  value       = azurerm_kubernetes_cluster.main.id
}

output "postgres_server_fqdn" {
  description = "Private PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database_name" {
  description = "PostgreSQL database name."
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID used by AKS monitoring."
  value       = azurerm_log_analytics_workspace.main.id
}
