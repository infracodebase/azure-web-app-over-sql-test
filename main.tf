data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = local.common_tags
}

# Log Analytics Workspace — central sink for all diagnostic settings
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_prefix}-law"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = local.common_tags
}

# Networking
module "networking" {
  source = "./modules/networking"

  name_prefix        = local.name_prefix
  resource_group     = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_address_space = var.vnet_address_space
  app_subnet_prefix  = var.app_subnet_prefix
  db_subnet_prefix   = var.db_subnet_prefix
  pe_subnet_prefix   = var.pe_subnet_prefix
  tags               = local.common_tags
}

# Key Vault
module "keyvault" {
  source = "./modules/keyvault"

  name_prefix                = local.name_prefix
  resource_group             = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku                        = var.kv_sku
  pe_subnet_id               = module.networking.pe_subnet_id
  vnet_id                    = module.networking.vnet_id
  allowed_subnet_ids         = [module.networking.app_subnet_id]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.common_tags
}

# SQL / PostgreSQL
module "sql" {
  source = "./modules/sql"

  name_prefix                = local.name_prefix
  resource_group             = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  db_subnet_id               = module.networking.db_subnet_id
  pe_subnet_id               = module.networking.pe_subnet_id
  vnet_id                    = module.networking.vnet_id
  private_dns_zone_id        = module.networking.postgres_private_dns_zone_id
  sku                        = var.db_sku
  storage_mb                 = var.db_storage_mb
  admin_username             = var.db_admin_username
  admin_password             = var.db_admin_password
  db_name                    = var.db_name
  key_vault_id               = module.keyvault.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.common_tags
}

# App Service
module "app_service" {
  source = "./modules/app-service"

  name_prefix                = local.name_prefix
  resource_group             = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  sku                        = var.app_service_sku
  app_subnet_id              = module.networking.app_subnet_id
  pe_subnet_id               = module.networking.pe_subnet_id
  vnet_id                    = module.networking.vnet_id
  key_vault_id               = module.keyvault.key_vault_id
  key_vault_uri              = module.keyvault.key_vault_uri
  db_host                    = module.sql.db_host
  db_name                    = var.db_name
  db_username                = var.db_admin_username
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.common_tags
}

# Grant App Service managed identity read access to Key Vault secrets
# Note: KV uses RBAC authorization — use azurerm_role_assignment instead of access policy
resource "azurerm_role_assignment" "app_service_kv_secrets" {
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_service.principal_id
}
