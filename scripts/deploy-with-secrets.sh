#!/bin/bash
# deployment/scripts/deploy-with-secrets.sh

set -e

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функції для виводу
error() { echo -e "${RED}❌ $1${NC}" >&2; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

# Конфігурація
RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
ENVIRONMENT="dev"
APP_NAME="django-app"
KEY_VAULT_NAME="${APP_NAME}-${ENVIRONMENT}-kv"

# Перевірка робочої директорії
if [ ! -f "manage.py" ]; then
    error "Запустіть скрипт з кореневої папки Django проекту"
    exit 1
fi

echo "🚀 Розгортання Django додатка з Key Vault..."
echo "📍 Resource Group: $RESOURCE_GROUP"
echo "🔐 Key Vault: $KEY_VAULT_NAME"
echo "🌍 Середовище: $ENVIRONMENT"
echo ""

# Перевірка Azure CLI
if ! command -v az &> /dev/null; then
    error "Azure CLI не встановлений"
    exit 1
fi

if ! az account show &>/dev/null; then
    error "Увійдіть в Azure CLI: az login"
    exit 1
fi

# Отримання поточного користувача
CURRENT_USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)
if [ -z "$CURRENT_USER_OBJECT_ID" ]; then
    error "Не вдалося отримати Object ID користувача"
    exit 1
fi

info "Користувач Object ID: $CURRENT_USER_OBJECT_ID"

# Створення Resource Group
info "Створення Resource Group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none

success "Resource Group готовий"

# Перевірка існування Bicep файлів
BICEP_FILE="deployment/azure/keyvault.bicep"
if [ ! -f "$BICEP_FILE" ]; then
    error "Bicep файл не знайдено: $BICEP_FILE"
    error "Створіть файл або запустіть з правильної директорії"
    exit 1
fi

# Розгортання Key Vault через Bicep
info "Розгортання Key Vault інфраструктури..."
DEPLOYMENT_NAME="keyvault-deployment-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file $BICEP_FILE \
    --parameters \
        environment=$ENVIRONMENT \
        appName=$APP_NAME \
        userObjectId=$CURRENT_USER_OBJECT_ID \
    --name $DEPLOYMENT_NAME \
    --output table

if [ $? -eq 0 ]; then
    success "Key Vault інфраструктура розгорнута"
else
    error "Помилка розгортання Bicep template"
    exit 1
fi

# Отримання Key Vault URL
KEY_VAULT_URL=$(az keyvault show \
    --name $KEY_VAULT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.vaultUri -o tsv)

if [ -z "$KEY_VAULT_URL" ]; then
    error "Не вдалося отримати URL Key Vault"
    exit 1
fi

success "Key Vault URL: $KEY_VAULT_URL"

# Очікування готовності Key Vault
info "Очікування готовності Key Vault (30 секунд)..."
sleep 30

# Генерація та встановлення секретів
info "Генерація та встановлення секретів..."

# 1. Django Secret Key
if command -v python3 &> /dev/null; then
    DJANGO_SECRET=$(python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
else
    DJANGO_SECRET=$(openssl rand -base64 50)
fi

az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "django-secret-key" \
    --value "$DJANGO_SECRET" \
    --output none

success "Django SECRET_KEY встановлено"

# 2. Database Password  
DATABASE_PASSWORD=$(openssl rand -base64 32)
az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "database-password" \
    --value "$DATABASE_PASSWORD" \
    --output none

success "Database password встановлено"

# 3. Storage Account Key (якщо існує Storage Account)
STORAGE_ACCOUNTS=$(az storage account list \
    --resource-group $RESOURCE_GROUP \
    --query "[0].name" -o tsv 2>/dev/null)

if [ -n "$STORAGE_ACCOUNTS" ]; then
    STORAGE_KEY=$(az storage account keys list \
        --resource-group $RESOURCE_GROUP \
        --account-name $STORAGE_ACCOUNTS \
        --query "[0].value" -o tsv)
    
    az keyvault secret set \
        --vault-name $KEY_VAULT_NAME \
        --name "azure-storage-key" \
        --value "$STORAGE_KEY" \
        --output none
    
    success "Storage Account key встановлено"
fi

# 4. Додаткові секрети
az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "email-host-password" \
    --value "change-me-email-password" \
    --output none

success "Email password placeholder встановлено"

# Створення або оновлення kv_vars.py
info "Створення конфігураційного файлу..."

cat > kv_vars.py << EOF
# kv_vars.py - НІКОЛИ НЕ КОМІТЬСЯ У GIT!
# Автоматично згенеровано $(date)

# Azure AD Authentication  
# Для розробки використовуйте Azure CLI або створіть Service Principal
AZURE_CLIENT_ID = ""  # Заповніть якщо використовуєте Service Principal
AZURE_CLIENT_SECRET = ""  # Заповніть якщо використовуєте Service Principal
AZURE_TENANT_ID = "$(az account show --query tenantId -o tsv)"

# Key Vault Configuration
AZURE_KEY_VAULT_URL = "$KEY_VAULT_URL"
SECRET_NAME = "django-secret-key"
SECRET_VERSION = ""  # Остання версія

# Додаткові секрети
DATABASE_SECRET_NAME = "database-password"
EMAIL_SECRET_NAME = "email-host-password"
STORAGE_SECRET_NAME = "azure-storage-key"
EOF

success "Файл kv_vars.py створено"

# Оновлення .gitignore
if [ -f .gitignore ]; then
    if ! grep -q "kv_vars.py" .gitignore; then
        echo "kv_vars.py" >> .gitignore
        success ".gitignore оновлено"
    fi
else
    echo "kv_vars.py" > .gitignore
    success ".gitignore створено"
fi

# Тестування доступу
info "Тестування доступу до секретів..."

TEST_SECRET=$(az keyvault secret show \
    --vault-name $KEY_VAULT_NAME \
    --name "django-secret-key" \
    --query value -o tsv 2>/dev/null)

if [ -n "$TEST_SECRET" ]; then
    success "Тест доступу пройшов успішно"
else
    warning "Не вдалося протестувати доступ до секретів"
fi

# Фінальний звіт
echo ""
echo "=================================================================="
success "Розгортання з Key Vault завершено!"
echo "=================================================================="
echo ""
echo "📊 Створені ресурси:"
echo "   • Resource Group: $RESOURCE_GROUP"
echo "   • Key Vault: $KEY_VAULT_NAME"  
echo "   • URL: $KEY_VAULT_URL"
echo ""
echo "🔐 Встановлені секрети:"
echo "   • django-secret-key"
echo "   • database-password" 
echo "   • email-host-password"
if [ -n "$STORAGE_ACCOUNTS" ]; then
    echo "   • azure-storage-key"
fi
echo ""
echo "📁 Створені файли:"
echo "   • kv_vars.py (конфігурація)"
echo "   • .gitignore (оновлено)"
echo ""
echo "🧪 Тестування:"
echo "   python3 -c \"from azure.keyvault.secrets import SecretClient; from azure.identity import DefaultAzureCredential; client = SecretClient('$KEY_VAULT_URL', DefaultAzureCredential()); print('Django Secret:', client.get_secret('django-secret-key').value[:20] + '...')\""
echo ""
echo "🔄 Наступні кроки:"
echo "   1. Інтегруйте Key Vault клієнт у Django settings"
echo "   2. Оновіть секрети реальними значеннями"
echo "   3. Налаштуйте Managed Identity для production"
echo ""
success "Готово! 🎉"
