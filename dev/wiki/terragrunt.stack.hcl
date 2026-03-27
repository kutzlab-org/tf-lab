locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_config      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name    = local.environment_config.locals.environment_name
  azure_region        = local.region_config.locals.azure_region
  resource_group_name = local.environment_config.locals.resource_group_name

  # EX_APP_PREFIX lets you namespace resources if multiple people share a subscription.
  # e.g. EX_APP_PREFIX=alice- gives "alice-core-services-dev"
  stack_name = "${get_env("EX_APP_PREFIX", "")}wiki-${local.environment_name}"
}

unit "law" {
  source = "${get_repo_root()}/units/log-analytics-workspace"
  path = "log-analytics-workspace"
  values = {
    name = "${local.stack_name}-law"
    resource_group_name = local.resource_group_name
    location = local.azure_region
  }
}

unit "cae" {
  source = "${get_repo_root()}/units/container-app-environment"
  path = "container-app-environment"
  values = {
    name = "${local.stack_name}-cae"
    resource_group_name = local.resource_group_name
    location = local.azure_region
    log_analytics_workspace_id = unit.law.outputs.id
  }
}