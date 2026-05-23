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
  description = "Azure region for networking resources."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
}

variable "app_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the App Service integration subnet."
}

variable "db_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the database subnet."
}

variable "pe_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the private endpoints subnet."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all networking resources."
  default     = {}
}
