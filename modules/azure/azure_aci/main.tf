resource "random_pet" "resource_group" {
  prefix = var.resource_group_name_prefix
}

resource "random_string" "container_name" {
  length  = 8
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "aci" {
  name     = random_pet.resource_group.id
  location = var.resource_group_location
}

resource "azurerm_container_group" "container" {
  name                = "${var.container_group_name_prefix}-${random_string.container_name.result}"
  location            = azurerm_resource_group.aci.location
  resource_group_name = azurerm_resource_group.aci.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = var.restart_policy

  container {
    name   = "${var.container_name_prefix}-${random_string.container_name.result}"
    image  = var.image
    cpu    = var.cpu_cores
    memory = var.memory_in_gb
    ports {
      port     = var.port
      protocol = "TCP"
    }
  }
}
