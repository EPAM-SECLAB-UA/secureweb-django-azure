#!/bin/bash
# deployment/scripts/deploy-with-secrets.sh

set -e

RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
ENVIRONMENT="production"
KEY_VAULT_NAME="django-app-${ENVIRONMENT}-kv"

echo "🚀 Розгортання з Key Vault..."

# Розгортання інфраструктури
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file deployment/azure/keyvault.bicep \
  --parameters environment=$ENVIRONMENT

# Генерація та встановлення секретів
echo "🔐 Встановлення секретів..."

# Django Secret Key
DJANGO_SECRET=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "django-secret-key" \
  --value "$DJANGO_SECRET"

# Database URL (від PostgreSQL deployment)
POSTGRES_SERVER=$(az postgres flexible-server list --resource-group $RESOURCE_GROUP --query "[0].fullyQualifiedDomainName" -o tsv)
POSTGRES_USER="dbadmin"
POSTGRES_PASSWORD=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name "postgres-password" --query value -o tsv 2>/dev/null || echo "TempPassword123!")
POSTGRES_DB="django_${ENVIRONMENT}"

DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}:5432/${POSTGRES_DB}"
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "database-url" \
  --value "$DATABASE_URL"

# Storage Account Key
STORAGE_ACCOUNT=$(az storage account list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "azure-storage-key" \
  --value "$STORAGE_KEY"

echo "✅ Секрети встановлено в Key Vault: $KEY_VAULT_NAME"
