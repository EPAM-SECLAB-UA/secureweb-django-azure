#!/bin/bash

# Змінні
RESOURCE_GROUP="django-app-rg"
KEY_VAULT_NAME="django-app-keyvault"
APP_NAME="django-app-keyvault"

echo "🚀 Створення повної конфігурації Azure Key Vault..."

# 1. Створення Resource Group
az group create --name $RESOURCE_GROUP --location westeurope

# 2. Створення Key Vault
az keyvault create \
    --name $KEY_VAULT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location westeurope

# 3. Створення Service Principal
SP_RESULT=$(az ad sp create-for-rbac --name $APP_NAME --skip-assignment)

# 4. Отримання значень
CLIENT_ID=$(echo $SP_RESULT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_RESULT | jq -r '.password')  
TENANT_ID=$(echo $SP_RESULT | jq -r '.tenant')
VAULT_URL=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query properties.vaultUri -o tsv)

# 5. Налаштування доступу
OBJECT_ID=$(az ad sp show --id $CLIENT_ID --query id -o tsv)
az keyvault set-policy \
    --name $KEY_VAULT_NAME \
    --object-id $OBJECT_ID \
    --secret-permissions get list

# 6. Додавання тестового секрету
az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "database-password" \
    --value "MySecretPassword123"

# 7. Виведення результатів
echo "✅ Конфігурація створена!"
echo ""
echo "📝 Додайте ці значення у ваш kv_vars.py:"
echo ""
echo "AZURE_CLIENT_ID = \"$CLIENT_ID\""
echo "AZURE_CLIENT_SECRET = \"$CLIENT_SECRET\""
echo "AZURE_TENANT_ID = \"$TENANT_ID\""
echo "AZURE_KEY_VAULT_URL = \"$VAULT_URL\""
echo "SECRET_NAME = \"database-password\""
echo "SECRET_VERSION = \"\"  # Остання версія"
echo ""
echo "🔒 ВАЖЛИВО: Не коміть CLIENT_SECRET у Git!"
