#!/usr/bin/env bash
# bootstrap-dev-backend.sh — Create the Azure Blob Storage backend for Terragrunt state.
#
# Run this once each time you get a new dev subscription. It creates:
#   - A resource group to hold the backend storage
#   - A storage account with a unique name
#   - A blob container for state files
#
# Then it prints the environment variables you need to export before running Terragrunt.
#
# Usage:
#   ./scripts/bootstrap-dev-backend.sh
#
# Prerequisites:
#   - az CLI installed and logged in (`az login`)
#   - ARM_SUBSCRIPTION_ID set (az login sets this automatically)

set -euo pipefail

SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-}"

if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "ERROR: ARM_SUBSCRIPTION_ID is not set." >&2
  echo "Run 'az login' first, or set ARM_SUBSCRIPTION_ID manually." >&2
  exit 1
fi

LOCATION="${TF_BACKEND_LOCATION:-eastus}"
RESOURCE_GROUP="${TF_BACKEND_RESOURCE_GROUP:-rg-tfstate-dev}"
CONTAINER="${TF_BACKEND_CONTAINER:-tfstate}"

# Generate a short random suffix to guarantee global uniqueness of the storage account name.
# Storage account names: 3-24 chars, lowercase alphanumeric only.
RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6)
STORAGE_ACCOUNT="sttfstatedev${RANDOM_SUFFIX}"

echo "Bootstrapping Terragrunt backend on subscription: $SUBSCRIPTION_ID"
echo "  Location:        $LOCATION"
echo "  Resource group:  $RESOURCE_GROUP"
echo "  Storage account: $STORAGE_ACCOUNT"
echo "  Container:       $CONTAINER"
echo ""

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --subscription "$SUBSCRIPTION_ID" \
  --output none

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

echo "Done. Export these variables before running Terragrunt:"
echo ""
echo "  export ARM_SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\""
echo "  export TF_BACKEND_RESOURCE_GROUP=\"$RESOURCE_GROUP\""
echo "  export TF_BACKEND_STORAGE_ACCOUNT=\"$STORAGE_ACCOUNT\""
echo "  export TF_BACKEND_CONTAINER=\"$CONTAINER\""
echo ""
echo "Then deploy dev:"
echo "  cd dev/eastus/core-services"
echo "  terragrunt stack run apply"
