# dev/eastus/core-services/terragrunt.stack.hcl — Dev core-services stack.
#
# HOW STACKS WORK:
#   A stack is a group of "units" that Terragrunt deploys together. Each unit
#   is an independent Terraform root module with its own state file. Stacks
#   let you express dependencies between units and deploy them in the right order.
#
#   `terragrunt run --all apply` inside this directory deploys all units.
#   `terragrunt stack run apply` does the same from the stack file.
#
# WHY TWO UNITS INSTEAD OF ONE MODULE?
#   Separate state files mean a failure in storage-account doesn't lock you out
#   of resource-group. It also means you can destroy/recreate individual pieces
#   without touching others — important for a frequently-reset dev environment.

locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_config      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name = local.environment_config.locals.environment_name
  azure_region     = local.region_config.locals.azure_region

  # EX_APP_PREFIX lets you namespace resources if multiple people share a subscription.
  # e.g. EX_APP_PREFIX=alice- gives "alice-core-services-dev"
  stack_name = "${get_env("EX_APP_PREFIX", "")}core-services-${local.environment_name}"

  # Derive the resource group name once so both units use the same value.
  resource_group_name = "rg-${local.stack_name}-${local.azure_region}"
}

unit "resource_group" {
  # Source points to the local unit directory. The // is not needed for local paths,
  # but the path must contain both .tf files and a terragrunt.hcl.
  source = "${get_repo_root()}/units/resource-group"
  path   = "resource-group"

  values = {
    name     = local.resource_group_name
    location = local.azure_region
    tags = {
      Environment = local.environment_name
      Stack       = local.stack_name
      ManagedBy   = "Terragrunt"
    }
  }
}

unit "storage_account" {
  source = "${get_repo_root()}/units/storage-account"
  path   = "storage-account"

  # depends_on tells Terragrunt to create resource_group before storage_account,
  # and destroy storage_account before resource_group.
  depends_on = [unit.resource_group]

  values = {
    # Azure storage account name constraints: 3-24 chars, lowercase alphanumeric only,
    # globally unique. We strip hyphens from the stack name and truncate to 24 chars.
    # Adjust or override if this conflicts with an existing account.
    name                     = substr(replace("st${local.stack_name}", "-", ""), 0, 24)
    resource_group_name      = local.resource_group_name
    location                 = local.azure_region
    account_tier             = "Standard"
    account_replication_type = "LRS"  # Cheapest option; fine for dev
    tags = {
      Environment = local.environment_name
      Stack       = local.stack_name
      ManagedBy   = "Terragrunt"
    }
  }
}
