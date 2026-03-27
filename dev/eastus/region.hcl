# dev/eastus/region.hcl — Region-level variables for eastus.
#
# To deploy dev in a second region, create dev/westus/region.hcl with
# azure_region = "westus" and duplicate the stack folder alongside it.
# root.hcl and environment.hcl need no changes.

locals {
  azure_region = "eastus"
}
