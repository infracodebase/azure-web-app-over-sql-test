data "azurerm_client_config" "current" {}

# PostgreSQL Flexible Server — VNet-injected, no public access
resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${var.name_prefix}-pg"
  resource_group_name = var.resource_group
  location            = var.location

  sku_name   = var.sku
  storage_mb = var.storage_mb
  version    = "16"

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  # VNet integration — no public endpoint
  delegated_subnet_id           = var.db_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  # Geo-redundant backup
  geo_redundant_backup_enabled  = true
  backup_retention_days         = 35

  high_availability {
    mode = "ZoneRedundant"
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  tags = var.tags
}

# Initial database
resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Enforce SSL
resource "azurerm_postgresql_flexible_server_configuration" "ssl" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

# Store DB password in Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "${var.name_prefix}-db-password"
  value        = var.admin_password
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "postgres" {
  name               = "${var.name_prefix}-pg-diag"
  target_resource_id = azurerm_postgresql_flexible_server.main.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
