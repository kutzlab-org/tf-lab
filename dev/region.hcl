# dev/region.hcl — Region config for the dev sandbox.
#
# Unlike prod, the dev environment doesn't let you choose a region. You're
# locked to whatever region the predefined resource group is in.
#
# The bootstrap script queries the RG's location and sets DEV_AZURE_REGION
# automatically. If you didn't use the bootstrap script, set it manually:
#   export DEV_AZURE_REGION=$(az group show -n $DEV_RESOURCE_GROUP --query location -o tsv)

locals {
  azure_region = get_env("DEV_AZURE_REGION")
}
