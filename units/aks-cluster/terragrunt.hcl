# This terragrunt.hcl is the Terragrunt wrapper for the aks-cluster Terraform module.
#
# HOW THIS FILE FITS INTO THE STACK:
#   A stack's terragrunt.stack.hcl defines units with a `values` block like:
#
#     unit "aks_cluster" {
#       source = ".../units/aks-cluster"
#       values = { name = "my-cluster", ... }
#     }
#
#   Terragrunt makes those values available here as `values.name`, `values.location`,
#   etc. This file's job is to map them into Terraform `inputs` — which Terraform
#   sees as `var.name`, `var.location`, etc.
#
#   Think of it as: stack (what to deploy) -> this file (glue) -> main.tf (how to deploy).

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name                = values.name
  resource_group_name = values.resource_group_name
  location            = values.location
  dns_prefix          = values.dns_prefix
  node_pool_vm_size   = values.node_pool_vm_size
  node_count          = values.node_count
  tags                = values.tags
}
