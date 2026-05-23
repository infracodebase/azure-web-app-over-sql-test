data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "${var.name_prefix}-kv"
  resource_group_name = var.resource_group
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.sku

  # Disable public access — enforce private endpoint only
  public_network_access_enabled   = false
  rbac_authorization_enabled      = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
    ip_rules                   = []
  }

  tags = var.tags
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = "${var.name_prefix}-kv-pe"
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Diagnostic settings — send audit logs to Log Analytics (workspace expected via variable or data source)
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name               = "${var.name_prefix}-kv-diag"
  target_resource_id = azurerm_key_vault.main.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
