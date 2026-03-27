variable "name" {
  description = "Name of the container app."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "container_image" {
  description = "Container image to deploy (e.g. mcr.microsoft.com/k8se/quickstart:latest)."
  type        = string
}

variable "container_name" {
  description = "Name of the container within the app."
  type        = string
  default     = "app"
}

variable "cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the container (e.g. 0.5Gi)."
  type        = string
  default     = "0.5Gi"
}

variable "revision_mode" {
  description = "Revision mode for the container app."
  type        = string
  default     = "Single"
}

variable "tags" {
  description = "Tags to apply to the container app."
  type        = map(string)
  default     = {}
}
