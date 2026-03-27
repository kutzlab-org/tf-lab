# root.hcl — Shared configuration inherited by every unit in this repo.
#
# HOW INHERITANCE WORKS:
#   Every unit's terragrunt.hcl has `include "root" { path = find_in_parent_folders("root.hcl") }`.
#   That causes Terragrunt to merge this file's config into the unit before running.
#   So the provider and backend below apply to every unit automatically — you never
#   repeat them.
#
# HOW HIERARCHICAL VARS WORK:
#   Terragrunt searches upward through the directory tree for environment.hcl and
#   region.hcl. Because of the layout:
#
#     <env>/environment.hcl       <- environment name, subscription ID
#     <env>/<region>/region.hcl   <- Azure region
#     <env>/<region>/<stack>/...  <- units live here
#
#   a unit in dev/eastus/core-services/ automatically picks up dev's environment.hcl
#   and eastus's region.hcl. Add a new environment by creating a folder — no changes
#   needed here.

locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_config      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name = local.environment_config.locals.environment_name
  subscription_id  = local.environment_config.locals.subscription_id
  azure_region     = local.region_config.locals.azure_region

  # Backend storage config — ALL from environment variables, no defaults.
  #
  # Why no defaults?
  #   - Storage account names must be globally unique in Azure; no generated name is safe.
  #   - Dev subscriptions rotate every few hours, so the backend changes with them.
  #
  # For dev: run scripts/bootstrap-dev-backend.sh on each new subscription.
  #          It creates the storage account and prints the vars to export.
  # For prod: set these once in your CI/CD secrets or shell profile.
  #
  # Required:
  #   TF_BACKEND_STORAGE_ACCOUNT — globally unique Azure storage account name
  #
  # Optional (have sensible defaults):
  #   TF_BACKEND_RESOURCE_GROUP  — defaults to rg-tfstate-<env>
  #   TF_BACKEND_CONTAINER       — defaults to "tfstate"
  backend_resource_group  = get_env("TF_BACKEND_RESOURCE_GROUP", "rg-tfstate-${local.environment_name}")
  backend_storage_account = get_env("TF_BACKEND_STORAGE_ACCOUNT")
  backend_container       = get_env("TF_BACKEND_CONTAINER", "tfstate")
}

# Generates provider.tf in every unit's working directory.
# Terragrunt overwrites this on each run — don't edit it by hand.
# The subscription_id is interpolated here by Terragrunt (not Terraform),
# so the generated file contains the literal subscription ID string.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }

    provider "azurerm" {
      features {}
      subscription_id = "${local.subscription_id}"
    }
  EOF
}

# Generates backend.tf in every unit's working directory.
# path_relative_to_include() returns the unit's path relative to root.hcl,
# e.g. "dev/eastus/core-services/.terragrunt-stack/resource-group".
# This gives each unit its own state file automatically — no manual key management.
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account
    container_name       = local.backend_container
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id      = local.subscription_id
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
