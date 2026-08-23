resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.aks_name}"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# AKS with managed identity, RBAC, local accounts disabled
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  node_provisioning_profile {
    mode = "Manual"
  }

  default_node_pool {
    name           = "nodepool1"
    node_count     = 2
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity { type = "SystemAssigned" }
  role_based_access_control_enabled = true
  local_account_disabled            = true

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent { log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id }
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "log-${var.aks_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Database for PostgreSQL Flexible Server (private)
resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "pg-${var.aks_name}"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  version                = var.postgres_version
  administrator_login    = var.postgres_admin
  administrator_password = var.postgres_password
  storage_mb             = 32768
  sku_name               = var.postgres_sku_name
  zone                   = "1"
  high_availability { mode = "ZoneRedundant" }
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

output "resource_group" { value = azurerm_resource_group.rg.name }
output "aks_name" { value = azurerm_kubernetes_cluster.aks.name }
output "postgres_fqdn" { value = azurerm_postgresql_flexible_server.pg.fqdn }
