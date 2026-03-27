include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name                = values.name
  resource_group_name = values.resource_group_name
  location            = values.location
  retention_in_days   = try(values.retention_in_days, 30)
  tags                = try(values.tags, {})
}
