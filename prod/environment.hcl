# prod/environment.hcl — Production environment variables.
#
# Uses a separate env var (PROD_ARM_SUBSCRIPTION_ID) rather than ARM_SUBSCRIPTION_ID.
# This is intentional: it prevents accidentally running a `terragrunt apply` against
# prod when you happen to be logged into the prod subscription for other work.
# You have to explicitly set PROD_ARM_SUBSCRIPTION_ID to target prod.

locals {
  environment_name = "prod"
  subscription_id  = get_env("PROD_ARM_SUBSCRIPTION_ID")
}
