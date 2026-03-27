# dev/environment.hcl — Dev environment variables.
#
# This file is automatically found by root.hcl via find_in_parent_folders().
# Any unit deployed under dev/ picks these up.
#
# DEV ROTATION WORKFLOW:
#   Dev gets a fresh subscription every few hours. When that happens:
#     1. az login  (or set ARM_* vars for your new tenant)
#     2. ./scripts/bootstrap-dev-backend.sh  (creates backend storage, prints env vars)
#     3. export the printed TF_BACKEND_* vars
#     4. Run terragrunt as normal
#
#   Nothing in this file needs to change — subscription_id reads from the env var
#   that az login sets automatically.

locals {
  environment_name = "dev"

  # ARM_SUBSCRIPTION_ID is set automatically by `az login` and by the Azure SDK/CLI.
  # When the dev subscription rotates, just re-login and this picks up the new value.
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
}
