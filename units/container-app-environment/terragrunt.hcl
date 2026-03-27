include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "law" {
  config_path = values.law_unit_path
}

inputs = {
  name                       = values.name
  resource_group_name        = values.resource_group_name
  location                   = values.location
  log_analytics_workspace_id = dependency.law.outputs.id
  tags                       = merge(include.root.locals.default_tags, try(values.tags, {}))
}
