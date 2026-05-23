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
  description = "Azure region for Key Vault resources."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for Key Vault access policies."
}

variable "sku" {
  type        = string
  description = "Key Vault SKU (standard or premium)."
  default     = "standard"
}

variable "pe_subnet_id" {
  type        = string
  description = "Subnet ID for the Key Vault private endpoint."
}

variable "vnet_id" {
  type        = string
  description = "Virtual network ID used for network rules."
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs allowed to access Key Vault via service endpoints."
  default     = []
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Key Vault resources."
  default     = {}
}
