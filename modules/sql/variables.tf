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
  description = "Azure region for database resources."
}

variable "db_subnet_id" {
  type        = string
  description = "Subnet ID for PostgreSQL VNet integration (delegated)."
}

variable "pe_subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint."
}

variable "vnet_id" {
  type        = string
  description = "Virtual network ID for DNS zone linkage."
}

variable "sku" {
  type        = string
  description = "PostgreSQL Flexible Server compute SKU."
  default     = "Standard_D2s_v3"
}

variable "storage_mb" {
  type        = number
  description = "Storage allocated in MB."
  default     = 32768
}

variable "admin_username" {
  type        = string
  description = "Administrator login username."
}

variable "admin_password" {
  type        = string
  description = "Administrator login password."
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Name of the initial database to create."
  default     = "appdb"
}

variable "private_dns_zone_id" {
  type        = string
  description = "Resource ID of the PostgreSQL private DNS zone for VNet-integrated server."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID for storing the DB password as a secret."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to database resources."
  default     = {}
}
