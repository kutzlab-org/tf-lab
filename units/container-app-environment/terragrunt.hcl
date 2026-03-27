include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name                       = values.name
  resource_group_name        = values.resource_group_name
  location                   = values.location
  log_analytics_workspace_id = values.log_analytics_workspace_id
  tags                       = try(values.tags, {})
}
