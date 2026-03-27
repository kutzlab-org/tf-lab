variable "name" {
  description = "Name of the Container App Environment."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the environment."
  type        = map(string)
  default     = {}
}
