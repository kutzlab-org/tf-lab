# dev/core-services/terragrunt.stack.hcl — Dev core-services stack.
#
# DEV SANDBOX CONSTRAINTS:
#   The dev sandbox provides a single predefined resource group. You cannot
#   create new resource groups. All resources deploy into the predefined RG,
#   in whatever region it lives in.
#
#   Because of this, there is NO resource_group unit here — only units that
#   deploy resources INTO the existing RG.
#
# USAGE:
#   cd dev/core-services
#   terragrunt stack run apply

locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_config      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name    = local.environment_config.locals.environment_name
  azure_region        = local.region_config.locals.azure_region
  resource_group_name = local.environment_config.locals.resource_group_name

  # EX_APP_PREFIX lets you namespace resources if multiple people share a subscription.
  # e.g. EX_APP_PREFIX=alice- gives "alice-core-services-dev"
  stack_name = "${get_env("EX_APP_PREFIX", "")}core-services-${local.environment_name}"
}

unit "storage_account" {
  source = "${get_repo_root()}/units/storage-account"
  path   = "storage-account"

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
