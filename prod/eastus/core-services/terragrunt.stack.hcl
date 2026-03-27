# prod/eastus/core-services/terragrunt.stack.hcl — Prod core-services stack.
#
# Structurally identical to dev's stack. The only differences that matter come
# from environment.hcl (environment_name = "prod", different subscription) and
# the prod-appropriate replication type for storage.

locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_config      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name = local.environment_config.locals.environment_name
  azure_region     = local.region_config.locals.azure_region

  stack_name          = "${get_env("EX_APP_PREFIX", "")}core-services-${local.environment_name}"
  resource_group_name = "rg-${local.stack_name}-${local.azure_region}"
}

unit "resource_group" {
  source = "${get_repo_root()}/units/resource-group"
  path   = "resource-group"

  values = {
    name     = local.resource_group_name
    location = local.azure_region
  }
}

unit "storage_account" {
  source     = "${get_repo_root()}/units/storage-account"
  path       = "storage-account"
  depends_on = [unit.resource_group]

  values = {
    name                     = substr(replace("st${local.stack_name}", "-", ""), 0, 24)
    resource_group_name      = local.resource_group_name
    location                 = local.azure_region
    account_tier             = "Standard"
    account_replication_type = "ZRS"  # Zone-redundant for prod resilience
  }
}
