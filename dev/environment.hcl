# dev/environment.hcl — Dev environment variables.
#
# This file is automatically found by root.hcl via find_in_parent_folders().
# Any unit deployed under dev/ picks these up.
#
# DEV SANDBOX CONSTRAINTS:
#   The dev environment is an ephemeral Azure sandbox that lasts ~3 hours.
#   You get ONE predefined resource group — you cannot create new ones.
#   All resources must be deployed into that resource group, in its region.
#   The subscription ID changes on every re-roll.
#
#   See docs/dev-sandbox-limits.md for allowed services, SKUs, and quotas.
#
# DEV ROTATION WORKFLOW:
#   When you get a new dev sandbox:
#     1. az login
#     2. Set DEV_RESOURCE_GROUP to the name of your predefined resource group
#     3. ./scripts/bootstrap-dev-backend.sh  (creates backend storage, prints env vars)
#     4. export the printed TF_BACKEND_* vars
#     5. Run terragrunt as normal
#
#   Nothing else needs to change — subscription_id and region are derived automatically.

locals {
  environment_name = "dev"

  # ARM_SUBSCRIPTION_ID is set automatically by `az login` and by the Azure SDK/CLI.
  # When the dev subscription rotates, just re-login and this picks up the new value.
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")

  # The predefined resource group you must deploy into.
  # Set this env var to match the RG assigned to your sandbox.
  resource_group_name = get_env("DEV_RESOURCE_GROUP")

  # The sandbox doesn't allow registering resource providers, so skip it.
  resource_provider_registrations = "none"
}
