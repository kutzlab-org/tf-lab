#!/usr/bin/env bash
# bootstrap-dev-backend.sh — Set up the Terragrunt state backend in the dev sandbox.
#
# Dev sandboxes provide a single predefined resource group. This script:
#   - Uses the predefined RG (does NOT create a new one)
#   - Queries the RG's location so you don't have to guess
#   - Creates a storage account + blob container for Terraform state inside that RG
#   - Prints the environment variables you need to export
#
# Usage:
#   export DEV_RESOURCE_GROUP="<your predefined RG name>"
#   ./scripts/bootstrap-dev-backend.sh
#
# Prerequisites:
#   - az CLI installed and logged in (`az login`)
#   - ARM_SUBSCRIPTION_ID set (az login sets this automatically)
#   - DEV_RESOURCE_GROUP set to your sandbox's predefined resource group name

set -euo pipefail
ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-}"
RESOURCE_GROUP="${DEV_RESOURCE_GROUP:-}"

if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "ERROR: ARM_SUBSCRIPTION_ID is not set." >&2
  echo "Run 'az login' first, or set ARM_SUBSCRIPTION_ID manually." >&2
  exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "ERROR: DEV_RESOURCE_GROUP is not set." >&2
  echo "Set it to the name of your sandbox's predefined resource group:" >&2
  echo "  export DEV_RESOURCE_GROUP=\"<your-rg-name>\"" >&2
  exit 1
fi

# Query the RG's location — this is the only region we can deploy to.
echo "Looking up resource group '$RESOURCE_GROUP'..."
LOCATION=$(az group show \
  --name "$RESOURCE_GROUP" \
  --subscription "$SUBSCRIPTION_ID" \
  --query location \
  --output tsv)

if [[ -z "$LOCATION" ]]; then
  echo "ERROR: Could not determine location for resource group '$RESOURCE_GROUP'." >&2
  echo "Make sure the RG exists and you have access to it." >&2
  exit 1
fi

CONTAINER="${TF_BACKEND_CONTAINER:-tfstate}"

# Generate a short random suffix to guarantee global uniqueness of the storage account name.
# Storage account names: 3-24 chars, lowercase alphanumeric only.
RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6)
STORAGE_ACCOUNT="sttfstatedev${RANDOM_SUFFIX}"

echo "Bootstrapping Terragrunt backend in predefined resource group"
echo "  Subscription:    $SUBSCRIPTION_ID"
echo "  Resource group:  $RESOURCE_GROUP"
echo "  Location:        $LOCATION"
echo "  Storage account: $STORAGE_ACCOUNT"
echo "  Container:       $CONTAINER"
echo ""

az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --allow-blob-public-access false \
  --subscription "$SUBSCRIPTION_ID" \
  --output none

az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --subscription "$SUBSCRIPTION_ID" \
  --output none

echo ""
echo "Done. Export these variables before running Terragrunt:"
echo ""
echo "  export ARM_SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\""
echo "  export DEV_RESOURCE_GROUP=\"$RESOURCE_GROUP\""
echo "  export DEV_AZURE_REGION=\"$LOCATION\""
echo "  export TF_BACKEND_RESOURCE_GROUP=\"$RESOURCE_GROUP\""
echo "  export TF_BACKEND_STORAGE_ACCOUNT=\"$STORAGE_ACCOUNT\""
echo "  export TF_BACKEND_CONTAINER=\"$CONTAINER\""
echo ""
echo "Then deploy dev:"
echo "  cd dev/core-services"
echo "  terragrunt stack run apply"
