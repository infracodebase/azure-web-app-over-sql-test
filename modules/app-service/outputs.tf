output "app_url" {
  description = "Default hostname of the App Service."
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_id" {
  description = "Resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.main.id
}

output "principal_id" {
  description = "Object ID of the App Service system-assigned managed identity."
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "service_plan_id" {
  description = "Resource ID of the App Service Plan."
  value       = azurerm_service_plan.main.id
}
