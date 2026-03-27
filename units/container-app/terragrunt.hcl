include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name                         = values.name
  resource_group_name          = values.resource_group_name
  container_app_environment_id = values.container_app_environment_id
  container_image              = values.container_image
  container_name               = try(values.container_name, "app")
  cpu                          = try(values.cpu, 0.25)
  memory                       = try(values.memory, "0.5Gi")
  revision_mode                = try(values.revision_mode, "Single")
  tags                         = try(values.tags, {})
}
