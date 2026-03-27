# This terragrunt.hcl is the Terragrunt wrapper for the resource-group Terraform module.
#
# Including root.hcl pulls in the Azure provider generation and the remote backend config.
# find_in_parent_folders() walks upward from wherever this unit is *deployed* (not where
# this file lives), so it correctly finds root.hcl at the repo root even when deployed
# into a stack's .terragrunt-stack/ subdirectory.

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name     = values.name
  location = values.location
  tags     = merge(include.root.locals.default_tags, try(values.tags, {}))
}
