variable "name_prefix" {
  type        = string
  description = "Prefix applied to all resource names."
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region for App Service resources."
}

variable "sku" {
  type        = string
  description = "App Service Plan SKU."
  default     = "P1v3"
}

variable "app_subnet_id" {
  type        = string
  description = "Subnet ID for VNet integration (outbound)."
}

variable "pe_subnet_id" {
  type        = string
  description = "Subnet ID for the App Service private endpoint (inbound)."
}

variable "vnet_id" {
  type        = string
  description = "Virtual network ID."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault resource ID for RBAC assignment."
}

variable "key_vault_uri" {
  type        = string
  description = "Key Vault URI for app setting references."
}

variable "db_host" {
  type        = string
  description = "PostgreSQL server FQDN."
}

variable "db_name" {
  type        = string
  description = "Database name."
}

variable "db_username" {
  type        = string
  description = "Database administrator username."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to App Service resources."
  default     = {}
}
