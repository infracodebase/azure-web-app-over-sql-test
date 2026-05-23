# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-asp"
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku

  tags = var.tags
}

# App Service (Linux Web App)
resource "azurerm_linux_web_app" "main" {
  name                = "${var.name_prefix}-app"
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  # Enforce HTTPS only
  https_only = true

  # VNet outbound integration
  virtual_network_subnet_id = var.app_subnet_id

  # System-assigned managed identity for Key Vault access
  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"

    # Disable basic auth for SCM and FTP
    scm_use_main_ip_restriction           = true
    ftps_state                            = "Disabled"

    application_stack {
      node_version = "20-lts"
    }

    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
  }

  # App settings — DB password referenced from Key Vault secret
  app_settings = {
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_PASSWORD = "@Microsoft.KeyVault(VaultName=${split("/", var.key_vault_id)[8]};SecretName=${var.name_prefix}-db-password)"

    WEBSITE_RUN_FROM_PACKAGE       = "1"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  # Diagnostic logs
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  tags = var.tags
}

# Private endpoint — locks inbound traffic to VNet only
resource "azurerm_private_endpoint" "app_service" {
  name                = "${var.name_prefix}-app-pe"
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-app-psc"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name               = "${var.name_prefix}-app-diag"
  target_resource_id = azurerm_linux_web_app.main.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
