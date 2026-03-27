variable "name" {
  description = "Name of the existing Log Analytics workspace to look up."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the workspace lives in."
  type        = string
}
