terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
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
  description = "Resource group for the serverless application."
  type        = string
  default     = "crft-static-functions-rg"
}

variable "name_prefix" {
  description = "Lowercase prefix used for resource names and tags."
  type        = string
  default     = "crft-web"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 4-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "static_web_app_name" {
  description = "Globally unique Azure Static Web App name."
  type        = string
  default     = "crft-static-web"
}

variable "static_web_app_sku_tier" {
  description = "Azure Static Web App SKU tier."
  type        = string
  default     = "Standard"
}

variable "static_web_app_sku_size" {
  description = "Azure Static Web App SKU size."
  type        = string
  default     = "Standard"
}

variable "function_app_name" {
  description = "Globally unique Azure Function App name."
  type        = string
  default     = "crft-functions-api"
}

variable "function_runtime" {
  description = "Function worker runtime. This template supports Node.js."
  type        = string
  default     = "node"

  validation {
    condition     = var.function_runtime == "node"
    error_message = "function_runtime must be node for this Node.js Function App template."
  }
}

variable "function_runtime_version" {
  description = "Node.js runtime version for the Linux Function App."
  type        = string
  default     = "20"
}

variable "function_plan_name" {
  description = "Name of the serverless Function App hosting plan."
  type        = string
  default     = "crft-functions-plan"
}

variable "storage_account_name" {
  description = "Globally unique storage account name; lowercase letters and numbers only."
  type        = string
  default     = "crftwebfuncstore"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters and contain only lowercase letters and numbers."
  }
}

variable "application_insights_name" {
  description = "Name of the Application Insights resource."
  type        = string
  default     = "crft-web-insights"
}

variable "log_analytics_workspace_name" {
  description = "Name of the workspace-backed Log Analytics workspace."
  type        = string
  default     = "crft-web-logs"
}

variable "log_retention_days" {
  description = "Log Analytics and Application Insights retention period in days."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730 days."
  }
}

variable "environment" {
  description = "Non-secret application settings passed to the Function App."
  type        = map(string)
  default     = {}
}

variable "cors_allowed_origins" {
  description = "Explicit browser origins allowed to call the Function App. Keep empty to configure CORS during application deployment."
  type        = list(string)
  default     = []
}

# --------------------------------------------------
# Resource group and tags
# --------------------------------------------------

locals {
  common_tags = {
    environment = "production"
    managed_by  = "terraform"
    product     = "crftinfrai"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# --------------------------------------------------
# Log Analytics and Application Insights
# --------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

# --------------------------------------------------
# Function storage and hosting plan
# --------------------------------------------------

resource "azurerm_storage_account" "function" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  tags                            = local.common_tags
}

resource "azurerm_service_plan" "function" {
  name                = var.function_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

# --------------------------------------------------
# Azure Function App
# --------------------------------------------------

resource "azurerm_linux_function_app" "main" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key
  https_only                 = true
  builtin_logging_enabled    = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = var.function_runtime_version
    }

    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = false
    }
  }

  app_settings = merge({
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    FUNCTIONS_WORKER_RUNTIME              = var.function_runtime
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
    WEBSITE_NODE_DEFAULT_VERSION          = "~${var.function_runtime_version}"
  }, var.environment)

  tags = local.common_tags
}

# --------------------------------------------------
# Azure Static Web App
# --------------------------------------------------

resource "azurerm_static_web_app" "main" {
  name                = var.static_web_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = var.static_web_app_sku_size
  tags                = local.common_tags
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "resource_group_name" {
  description = "Resource group containing the serverless application."
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region containing the deployment."
  value       = azurerm_resource_group.main.location
}

output "static_web_app_name" {
  description = "Azure Static Web App name."
  value       = azurerm_static_web_app.main.name
}

output "static_web_app_hostname" {
  description = "Azure Static Web App default hostname."
  value       = azurerm_static_web_app.main.default_host_name
}

output "function_app_name" {
  description = "Azure Function App name."
  value       = azurerm_linux_function_app.main.name
}

output "function_app_hostname" {
  description = "Azure Function App default hostname."
  value       = azurerm_linux_function_app.main.default_hostname
}

output "application_insights_name" {
  description = "Application Insights resource name."
  value       = azurerm_application_insights.main.name
}

output "log_analytics_workspace_id" {
  description = "Workspace-backed Log Analytics resource ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "storage_account_name" {
  description = "Function App storage account name."
  value       = azurerm_storage_account.function.name
}
