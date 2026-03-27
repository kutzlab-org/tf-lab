variable "name" {
  description = "Storage account name. Must be 3-24 chars, lowercase alphanumeric, globally unique."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy the storage account into."
  type        = string
}

variable "location" {
  description = "Azure region (must match the resource group's region)."
  type        = string
}

variable "account_tier" {
  description = "Performance tier: Standard or Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication strategy: LRS, ZRS, GRS, RAGRS, etc."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags to apply to the storage account."
  type        = map(string)
  default     = {}
}
