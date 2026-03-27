#!/usr/bin/env bash
# bootstrap-dev-backend.sh — Set up the Terragrunt state backend in the dev sandbox.
#
# Dev sandboxes provide a single predefined resource group. This script:
#   - Uses the predefined RG (does NOT create a new one)
#   - Queries the RG's location so you don't have to guess
#   - Creates a storage account + blob container for Terraform state (skips if already exists)
#   - Exports the required environment variables into your current shell
#
# Usage (must be sourced, not executed):
#   export DEV_RESOURCE_GROUP="<your predefined RG name>"
#   source ./scripts/bootstrap-dev-backend.sh

# Guard: env vars can only be exported into the parent shell if this script is sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "ERROR: This script must be sourced, not executed directly." >&2
  echo "Run: source ./scripts/bootstrap-dev-backend.sh" >&2
  exit 1
fi

# ---------------------------------------------------------------------------

export ARM_SUBSCRIPTION_ID="a2b28c85-1948-4263-90ca-bade2bac4df4"

if [[ -z "${DEV_RESOURCE_GROUP:-}" ]]; then
  echo "ERROR: DEV_RESOURCE_GROUP is not set." >&2
  echo "Set it to your sandbox's predefined resource group and re-source:" >&2
  echo "  export DEV_RESOURCE_GROUP=\"<your-rg-name>\"" >&2
  return 1
fi

# Query the RG's location — this is the only region we can deploy to.
echo "Looking up resource group '$DEV_RESOURCE_GROUP'..."
LOCATION=$(az group show \
  --name "$DEV_RESOURCE_GROUP" \
  --subscription "$ARM_SUBSCRIPTION_ID" \
  --query location \
  --output tsv)

if [[ -z "$LOCATION" ]]; then
  echo "ERROR: Could not determine location for '$DEV_RESOURCE_GROUP'." >&2
  echo "Make sure the RG exists and you are logged in ('az login')." >&2
  return 1
fi

CONTAINER="${TF_BACKEND_CONTAINER:-tfstate}"

# Reuse an existing backend storage account if one was already created for this RG,
# otherwise create a new one with a random suffix for global uniqueness.
EXISTING=$(az storage account list \
  --resource-group "$DEV_RESOURCE_GROUP" \
  --subscription "$ARM_SUBSCRIPTION_ID" \
  --query "[?starts_with(name, 'sttfstatedev')].name | [0]" \
  --output tsv)

if [[ -n "$EXISTING" ]]; then
  STORAGE_ACCOUNT="$EXISTING"
  echo "Reusing existing backend storage account: $STORAGE_ACCOUNT"
else
  RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6)
  STORAGE_ACCOUNT="sttfstatedev${RANDOM_SUFFIX}"
  echo "Creating backend storage account: $STORAGE_ACCOUNT"

  az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$DEV_RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --allow-blob-public-access false \
    --subscription "$ARM_SUBSCRIPTION_ID" \
    --output none

  az storage container create \
    --name "$CONTAINER" \
    --account-name "$STORAGE_ACCOUNT" \
    --subscription "$ARM_SUBSCRIPTION_ID" \
    --output none
fi

export DEV_AZURE_REGION="$LOCATION"
export TF_BACKEND_RESOURCE_GROUP="$DEV_RESOURCE_GROUP"
export TF_BACKEND_STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
export TF_BACKEND_CONTAINER="$CONTAINER"

echo ""
echo "Environment ready:"
echo "  ARM_SUBSCRIPTION_ID      = $ARM_SUBSCRIPTION_ID"
echo "  DEV_RESOURCE_GROUP       = $DEV_RESOURCE_GROUP"
echo "  DEV_AZURE_REGION         = $DEV_AZURE_REGION"
echo "  TF_BACKEND_RESOURCE_GROUP  = $TF_BACKEND_RESOURCE_GROUP"
echo "  TF_BACKEND_STORAGE_ACCOUNT = $TF_BACKEND_STORAGE_ACCOUNT"
echo "  TF_BACKEND_CONTAINER       = $TF_BACKEND_CONTAINER"
echo ""
echo "Deploy dev:"
echo "  cd dev/core-services && terragrunt stack run apply"
