variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy resources into."
}

variable "location" {
  type        = string
  description = "Primary Azure region for all resources."
  default     = "eastus2"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "app_name" {
  type        = string
  description = "Base application name used for naming all resources."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to merge onto all resources."
  default     = {}
}

# Networking
variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the App Service integration subnet."
  default     = "10.0.1.0/24"
}

variable "db_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the database subnet."
  default     = "10.0.2.0/24"
}

variable "pe_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the private endpoints subnet."
  default     = "10.0.3.0/24"
}

# App Service
variable "app_service_sku" {
  type        = string
  description = "App Service Plan SKU (e.g., P1v3, P2v3)."
  default     = "P1v3"
}

# SQL / PostgreSQL
variable "db_sku" {
  type        = string
  description = "PostgreSQL Flexible Server SKU."
  default     = "Standard_D2s_v3"
}

variable "db_storage_mb" {
  type        = number
  description = "Storage in MB allocated to the PostgreSQL server."
  default     = 32768
}

variable "db_admin_username" {
  type        = string
  description = "Administrator username for the PostgreSQL server."
  default     = "pgadmin"
}

variable "db_admin_password" {
  type        = string
  description = "Administrator password for the PostgreSQL server."
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Name of the initial PostgreSQL database."
  default     = "appdb"
}

# Key Vault
variable "kv_sku" {
  type        = string
  description = "Key Vault SKU (standard or premium)."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.kv_sku)
    error_message = "kv_sku must be standard or premium."
  }
}
