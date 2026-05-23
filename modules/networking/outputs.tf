output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "app_subnet_id" {
  description = "Resource ID of the App Service integration subnet."
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "Resource ID of the database subnet."
  value       = azurerm_subnet.db.id
}

output "pe_subnet_id" {
  description = "Resource ID of the private endpoints subnet."
  value       = azurerm_subnet.pe.id
}

output "keyvault_private_dns_zone_id" {
  description = "Resource ID of the Key Vault private DNS zone."
  value       = azurerm_private_dns_zone.keyvault.id
}

output "postgres_private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL private DNS zone."
  value       = azurerm_private_dns_zone.postgres.id
}
