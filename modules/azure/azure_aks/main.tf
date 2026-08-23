// filename: main.tf

locals {
  create_net = var.network_mode == "create"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Network (create)
resource "azurerm_virtual_network" "vnet" {
  count               = local.create_net ? 1 : 0
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  count                = local.create_net ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.subnet_cidr]
}

locals {
  subnet_id = local.create_net ? azurerm_subnet.subnet[0].id : var.existing_subnet_id
}

# Cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster

  # This module uses the traditional VM scale set node pool implementation;
  # Azure Node Auto Provisioning is intentionally not enabled.
  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                 = "np01"
    vm_size              = var.node_vm_size
    node_count           = var.node_count
    min_count            = var.node_min
    max_count            = var.node_max
    auto_scaling_enabled = var.node_max > var.node_min
    vnet_subnet_id       = local.subnet_id
    os_disk_size_gb      = var.node_disk_gb
    type                 = "VirtualMachineScaleSets"
    max_pods             = 110
  }

  network_profile {
    network_plugin    = var.network_plugin # "azure" or "kubenet"
    network_policy    = var.network_policy # "calico" or "azure" (when plugin=azure)
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.api_authorized_ip_ranges
  }

  tags = var.tags
}
