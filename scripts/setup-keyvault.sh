#!/bin/bash

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функція для виводу помилок
error() {
    echo -e "${RED}❌ Помилка: $1${NC}" >&2
}

# Функція для виводу успіху
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Функція для виводу попереджень
warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Функція для виводу інформації
info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Функція для питання користувача
ask_user() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Введіть y або n.";;
        esac
    done
}

# Змінні
RESOURCE_GROUP="django-app-rg"
KEY_VAULT_NAME="django-app-keyvault"
APP_NAME="django-app-keyvault"

echo "🚀 Налаштування Azure Key Vault конфігурації..."

# Перевірка чи користувач залогінений
if ! az account show &>/dev/null; then
    error "Ви не залогінені в Azure CLI. Запустіть: az login"
    exit 1
fi

# Отримання поточного користувача
CURRENT_USER=$(az account show --query user.name -o tsv)
CURRENT_USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)

if [ -z "$CURRENT_USER_OBJECT_ID" ]; then
    error "Не вдалося отримати Object ID поточного користувача"
    exit 1
fi

info "Поточний користувач: $CURRENT_USER"
info "Object ID: $CURRENT_USER_OBJECT_ID"

# 1. Перевірка та створення Resource Group
echo ""
info "Крок 1/7: Перевірка Resource Group..."

if az group show --name $RESOURCE_GROUP &>/dev/null; then
    warning "Resource Group вже існує: $RESOURCE_GROUP"
    if ask_user "Використати існуючий Resource Group?"; then
        success "Використовуємо існуючий Resource Group"
    else
        info "Виберіть іншу назву або видаліть існуючий: az group delete --name $RESOURCE_GROUP"
        exit 1
    fi
else
    if az group create --name $RESOURCE_GROUP --location westeurope --output none; then
        success "Resource Group створено: $RESOURCE_GROUP"
    else
        error "Не вдалося створити Resource Group"
        exit 1
    fi
fi

# 2. Перевірка та створення Key Vault
echo ""
info "Крок 2/7: Перевірка Key Vault..."

if az keyvault show --name $KEY_VAULT_NAME &>/dev/null; then
    warning "Key Vault вже існує: $KEY_VAULT_NAME"
    if ask_user "Використати існуючий Key Vault?"; then
        success "Використовуємо існуючий Key Vault"
        
        # Перевірка чи є RBAC включено
        RBAC_ENABLED=$(az keyvault show --name $KEY_VAULT_NAME --query properties.enableRbacAuthorization -o tsv)
        if [ "$RBAC_ENABLED" = "true" ]; then
            info "Key Vault використовує RBAC авторизацію"
            USE_RBAC=true
        else
            info "Key Vault використовує Access Policies"
            USE_RBAC=false
        fi
    else
        # Пропонуємо унікальну назву
        TIMESTAMP=$(date +%s)
        NEW_VAULT_NAME="${KEY_VAULT_NAME}-${TIMESTAMP}"
        warning "Спробуйте унікальну назву: $NEW_VAULT_NAME"
        
        if ask_user "Створити Key Vault з назвою $NEW_VAULT_NAME?"; then
            KEY_VAULT_NAME=$NEW_VAULT_NAME
        else
            exit 1
        fi
    fi
fi

# Створення нового Key Vault якщо потрібно
if ! az keyvault show --name $KEY_VAULT_NAME &>/dev/null; then
    info "Створення нового Key Vault: $KEY_VAULT_NAME"
    if az keyvault create \
        --name $KEY_VAULT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location westeurope \
        --enable-rbac-authorization false \
        --output none; then
        success "Key Vault створено: $KEY_VAULT_NAME"
        USE_RBAC=false
    else
        error "Не вдалося створити Key Vault"
        exit 1
    fi
fi

# 2.1. Налаштування прав доступу для поточного користувача
echo ""
info "Крок 2.1/7: Налаштування прав доступу..."

if [ "$USE_RBAC" = "true" ]; then
    # Використання RBAC
    info "Налаштування RBAC прав..."
    VAULT_SCOPE="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
    
    if az role assignment create \
        --assignee $CURRENT_USER_OBJECT_ID \
        --role "Key Vault Secrets Officer" \
        --scope $VAULT_SCOPE \
        --output none 2>/dev/null; then
        success "RBAC права надано: Key Vault Secrets Officer"
    else
        warning "Не вдалося надати RBAC права (можливо, вже існують)"
    fi
else
    # Використання Access Policies
    info "Налаштування Access Policies..."
    if az keyvault set-policy \
        --name $KEY_VAULT_NAME \
        --object-id $CURRENT_USER_OBJECT_ID \
        --secret-permissions get list set delete backup restore recover \
        --output none; then
        success "Access Policy налаштовано для користувача"
    else
        warning "Не вдалося налаштувати Access Policy"
    fi
fi

# 3. Спроба створення Service Principal
echo ""
info "Крок 3/7: Створення Service Principal..."

# Перевірка чи вже існує
if az ad app show --id "http://$APP_NAME" &>/dev/null; then
    warning "Додаток вже існує, отримуємо існуючі дані..."
    CLIENT_ID=$(az ad app show --id "http://$APP_NAME" --query appId -o tsv)
    
    # Створення нового секрету
    SECRET_RESULT=$(az ad app credential reset --id $CLIENT_ID --display-name "Django KeyVault Access $(date +%Y%m%d)" 2>/dev/null)
    if [ $? -eq 0 ]; then
        CLIENT_SECRET=$(echo $SECRET_RESULT | jq -r '.password')
        success "Новий Client Secret створено для існуючого додатка"
    else
        warning "Не вдалося створити новий secret для існуючого додатка"
        CLIENT_SECRET=""
    fi
else
    # Створення нового додатка
    APP_RESULT=$(az ad app create --display-name $APP_NAME 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        CLIENT_ID=$(echo $APP_RESULT | jq -r '.appId')
        success "Додаток створено: $CLIENT_ID"
        
        # Створення Service Principal
        if az ad sp create --id $CLIENT_ID --output none 2>/dev/null; then
            success "Service Principal створено"
            
            # Створення client secret
            SECRET_RESULT=$(az ad app credential reset --id $CLIENT_ID --display-name "Django KeyVault Access" 2>/dev/null)
            if [ $? -eq 0 ]; then
                CLIENT_SECRET=$(echo $SECRET_RESULT | jq -r '.password')
                success "Client Secret створено"
            else
                warning "Не вдалося створити Client Secret"
                CLIENT_SECRET=""
            fi
        else
            warning "Не вдалося створити Service Principal"
            CLIENT_SECRET=""
        fi
    else
        warning "Недостатньо прав для створення Service Principal"
        warning "Використовуйте Azure CLI authentication для розробки"
        CLIENT_ID=""
        CLIENT_SECRET=""
    fi
fi

TENANT_ID=$(az account show --query tenantId -o tsv)

# 4. Отримання URL Key Vault
echo ""
info "Крок 4/7: Отримання URL Key Vault..."
VAULT_URL=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query properties.vaultUri -o tsv)
if [ $? -eq 0 ]; then
    success "URL Key Vault: $VAULT_URL"
else
    error "Не вдалося отримати URL Key Vault"
    exit 1
fi

# 5. Налаштування доступу для Service Principal
if [ -n "$CLIENT_ID" ]; then
    echo ""
    info "Крок 5/7: Налаштування доступу для Service Principal..."
    
    SP_OBJECT_ID=$(az ad sp show --id $CLIENT_ID --query id -o tsv 2>/dev/null)
    
    if [ -n "$SP_OBJECT_ID" ]; then
        if [ "$USE_RBAC" = "true" ]; then
            # RBAC для Service Principal
            VAULT_SCOPE="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
            if az role assignment create \
                --assignee $SP_OBJECT_ID \
                --role "Key Vault Secrets User" \
                --scope $VAULT_SCOPE \
                --output none 2>/dev/null; then
                success "RBAC права для Service Principal налаштовано"
            else
                warning "Не вдалося налаштувати RBAC для Service Principal"
            fi
        else
            # Access Policy для Service Principal
            if az keyvault set-policy \
                --name $KEY_VAULT_NAME \
                --object-id $SP_OBJECT_ID \
                --secret-permissions get list \
                --output none; then
                success "Access Policy для Service Principal налаштовано"
            else
                warning "Не вдалося налаштувати Access Policy для Service Principal"
            fi
        fi
    else
        warning "Не вдалося отримати Object ID Service Principal"
    fi
else
    echo ""
    warning "Крок 5/7: Service Principal не створено, пропускаємо"
fi

# 6. Додавання тестового секрету
echo ""
info "Крок 6/7: Додавання тестового секрету..."

# Очікування поширення прав (якщо використовуємо RBAC)
if [ "$USE_RBAC" = "true" ]; then
    info "Очікування поширення RBAC прав (15 секунд)..."
    sleep 15
else
    info "Очікування поширення прав (5 секунд)..."
    sleep 5
fi

if az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "database-password" \
    --value "MySecretPassword123" \
    --output none; then
    success "Тестовий секрет 'database-password' додано"
else
    warning "Не вдалося додати тестовий секрет"
    info "Спробуйте вручну через кілька хвилин:"
    info "az keyvault secret set --vault-name $KEY_VAULT_NAME --name 'database-password' --value 'YourPassword'"
fi

# 7. Створення файлу kv_vars.py
echo ""
info "Крок 7/7: Створення файлу конфігурації..."

cat > kv_vars.py << EOF
# kv_vars.py - НІКОЛИ НЕ КОМІТЬСЯ У GIT!
import os

# Azure AD Authentication
EOF

if [ -n "$CLIENT_ID" ]; then
    cat >> kv_vars.py << EOF
AZURE_CLIENT_ID = "$CLIENT_ID"
AZURE_CLIENT_SECRET = "$CLIENT_SECRET"
EOF
else
    cat >> kv_vars.py << EOF
# Service Principal не створено - використовуйте альтернативні методи
AZURE_CLIENT_ID = ""  # Заповніть вручну або використовуйте Managed Identity
AZURE_CLIENT_SECRET = ""  # Заповніть вручну або використовуйте Managed Identity
EOF
fi

cat >> kv_vars.py << EOF
AZURE_TENANT_ID = "$TENANT_ID"

# Key Vault Configuration
AZURE_KEY_VAULT_URL = "$VAULT_URL"
SECRET_NAME = "database-password"
SECRET_VERSION = ""  # Остання версія
EOF

success "Файл kv_vars.py створено"

# Додавання до .gitignore
if [ -f .gitignore ]; then
    if ! grep -q "kv_vars.py" .gitignore; then
        echo "kv_vars.py" >> .gitignore
        success "kv_vars.py додано до .gitignore"
    else
        info "kv_vars.py вже в .gitignore"
    fi
else
    echo "kv_vars.py" > .gitignore
    success ".gitignore створено з kv_vars.py"
fi

# Фінальний звіт
echo ""
echo "=================================================================="
success "Конфігурація Azure Key Vault завершена!"
echo "=================================================================="
echo ""
echo "📊 Створені ресурси:"
echo "   • Resource Group: $RESOURCE_GROUP"
echo "   • Key Vault: $KEY_VAULT_NAME"
echo "   • URL: $VAULT_URL"
if [ -n "$CLIENT_ID" ]; then
    echo "   • Service Principal: $CLIENT_ID"
    echo "   • Authorization: $([ "$USE_RBAC" = "true" ] && echo "RBAC" || echo "Access Policies")"
fi
echo ""
echo "📁 Створені файли:"
echo "   • kv_vars.py (з конфігурацією)"
echo "   • .gitignore (оновлено)"
echo ""

if [ -z "$CLIENT_ID" ]; then
    echo "⚠️ Service Principal не створено через недостатні права"
    echo ""
    echo "🔄 Альтернативи для розробки:"
    echo ""
    echo "1. Azure CLI Authentication:"
    echo "   # У вашому Python коді:"
    echo "   from azure.identity import AzureCliCredential"
    echo "   credential = AzureCliCredential()"
    echo ""
    echo "2. Змінні середовища:"
    echo "   export AZURE_CLIENT_ID=\"your-client-id\""
    echo "   export AZURE_CLIENT_SECRET=\"your-client-secret\""
    echo "   export AZURE_TENANT_ID=\"$TENANT_ID\""
    echo ""
fi

echo "🧪 Тестування доступу:"
echo "   python3 -c \"from azure.keyvault.secrets import SecretClient; from azure.identity import DefaultAzureCredential; client = SecretClient('$VAULT_URL', DefaultAzureCredential()); print('Secret:', client.get_secret('database-password').value)\""
echo ""
echo "🔒 Пам'ятайте:"
echo "   • НЕ коміть kv_vars.py у Git"
echo "   • Використовуйте Managed Identity у production"
echo "   • Регулярно ротуйте секрети"
echo ""
success "Готово! Key Vault налаштовано та готовий до використання."
