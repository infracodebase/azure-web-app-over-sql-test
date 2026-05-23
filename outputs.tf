output "resource_group_name" {
  description = "Name of the deployed resource group."
  value       = azurerm_resource_group.main.name
}

output "app_service_url" {
  description = "Default hostname of the App Service."
  value       = module.app_service.app_url
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.keyvault.key_vault_uri
}

output "db_host" {
  description = "FQDN of the PostgreSQL Flexible Server."
  value       = module.sql.db_host
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = module.networking.vnet_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.id
}
