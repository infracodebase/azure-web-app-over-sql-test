output "db_host" {
  description = "Fully qualified domain name of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "db_id" {
  description = "Resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.id
}

output "db_password_secret_id" {
  description = "Key Vault secret ID for the database password."
  value       = azurerm_key_vault_secret.db_password.id
}
