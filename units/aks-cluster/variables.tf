variable "name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy the AKS cluster into."
  type        = string
}

variable "location" {
  description = "Azure region for the cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster's FQDN (<prefix>.<region>.azmk8s.io). Must be unique within the region."
  type        = string
}

variable "node_pool_vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply to the AKS cluster."
  type        = map(string)
  default     = {}
}
