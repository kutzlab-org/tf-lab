include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name                     = values.name
  resource_group_name      = values.resource_group_name
  location                 = values.location
  account_tier             = values.account_tier
  account_replication_type = values.account_replication_type
  tags                     = merge(include.root.locals.default_tags, try(values.tags, {}))
}
