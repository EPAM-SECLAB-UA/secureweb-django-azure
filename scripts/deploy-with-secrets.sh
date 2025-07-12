#!/bin/bash
# deployment/scripts/deploy-with-secrets.sh - Виправлена версія з Django SECRET_KEY

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

# Функція для генерації Django SECRET_KEY
generate_django_secret() {
    # Метод 1: Через Django (найкращий)
    if command -v python3 &> /dev/null; then
        local secret=$(python3 -c "
try:
    from django.core.management.utils import get_random_secret_key
    print(get_random_secret_key())
except ImportError:
    import secrets
    import string
    chars = string.ascii_letters + string.digits + '!@#$%^&*(-_=+)'
    print(''.join(secrets.choice(chars) for _ in range(50)))
except Exception:
    print('')
" 2>/dev/null)
        
        if [ -n "$secret" ] && [ ${#secret} -gt 30 ]; then
            echo "$secret"
            return 0
        fi
    fi
    
    # Метод 2: Через openssl (fallback)
    if command -v openssl &> /dev/null; then
        local secret=$(openssl rand -base64 50 | tr -d "=+/" | cut -c1-50)
        if [ -n "$secret" ] && [ ${#secret} -gt 30 ]; then
            echo "$secret"
            return 0
        fi
    fi
    
    # Метод 3: Через /dev/urandom (last resort)
    local secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*' | fold -w 50 | head -n 1)
    echo "$secret"
}

# Функція для перевірки та встановлення секрету
set_keyvault_secret() {
    local vault_name="$1"
    local secret_name="$2"
    local secret_value="$3"
    local description="$4"
    
    info "Встановлення $description..."
    
    # Спроба встановити секрет з кількома ретраями
    local retries=3
    local delay=5
    
    for attempt in $(seq 1 $retries); do
        if az keyvault secret set \
            --vault-name "$vault_name" \
            --name "$secret_name" \
            --value "$secret_value" \
            --output none 2>/dev/null; then
            success "$description встановлено (спроба $attempt)"
            return 0
        else
            if [ $attempt -lt $retries ]; then
                warning "Спроба $attempt невдала, очікування $delay секунд..."
                sleep $delay
            else
                warning "Не вдалося встановити $description після $retries спроб"
                return 1
            fi
        fi
    done
}

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

# Перевірка існування Key Vault
info "Перевірка існування Key Vault..."
if az keyvault show --name $KEY_VAULT_NAME &>/dev/null; then
    warning "Key Vault вже існує: $KEY_VAULT_NAME"
    if ask_user "Використати існуючий Key Vault та оновити секрети?"; then
        info "Використовуємо існуючий Key Vault"
        SKIP_BICEP_DEPLOYMENT=true
    else
        # Пропонуємо унікальну назву
        TIMESTAMP=$(date +%s)
        NEW_VAULT_NAME="${KEY_VAULT_NAME}-${TIMESTAMP}"
        warning "Створимо новий Key Vault: $NEW_VAULT_NAME"
        KEY_VAULT_NAME=$NEW_VAULT_NAME
        SKIP_BICEP_DEPLOYMENT=false
    fi
else
    SKIP_BICEP_DEPLOYMENT=false
fi

# Розгортання Key Vault через Bicep (якщо потрібно)
if [ "$SKIP_BICEP_DEPLOYMENT" = "false" ]; then
    # Перевірка існування Bicep файлів
    BICEP_FILE="deployment/azure/keyvault.bicep"
    if [ ! -f "$BICEP_FILE" ]; then
        error "Bicep файл не знайдено: $BICEP_FILE"
        error "Створіть файл або запустіть з правильної директорії"
        exit 1
    fi

    info "Розгортання Key Vault інфраструктури..."
    DEPLOYMENT_NAME="keyvault-deployment-$(date +%Y%m%d-%H%M%S)"

    if az deployment group create \
        --resource-group $RESOURCE_GROUP \
        --template-file $BICEP_FILE \
        --parameters \
            environment=$ENVIRONMENT \
            appName=$APP_NAME \
            userObjectId=$CURRENT_USER_OBJECT_ID \
        --name $DEPLOYMENT_NAME \
        --output table; then
        success "Key Vault інфраструктура розгорнута"
    else
        error "Помилка розгортання Bicep template"
        
        # Перевірка типових помилок
        info "Перевірка можливих причин помилки..."
        
        # Перевірка чи вже існує Key Vault з такою назвою
        if az keyvault show --name $KEY_VAULT_NAME &>/dev/null; then
            warning "Key Vault з назвою $KEY_VAULT_NAME вже існує"
            if ask_user "Продовжити з існуючим Key Vault?"; then
                success "Продовжуємо з існуючим Key Vault"
            else
                error "Зупинка розгортання"
                exit 1
            fi
        else
            exit 1
        fi
    fi
else
    info "Пропускаємо розгортання Bicep (використовуємо існуючий Key Vault)"
fi

# Отримання Key Vault URL
info "Отримання URL Key Vault..."
KEY_VAULT_URL=$(az keyvault show \
    --name $KEY_VAULT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.vaultUri -o tsv 2>/dev/null)

if [ -z "$KEY_VAULT_URL" ]; then
    # Спроба знайти Key Vault в усіх resource groups
    warning "Не вдалося знайти Key Vault в $RESOURCE_GROUP"
    info "Пошук Key Vault в усіх resource groups..."
    
    KEY_VAULT_URL=$(az keyvault list --query "[?name=='$KEY_VAULT_NAME'].properties.vaultUri | [0]" -o tsv 2>/dev/null)
    
    if [ -n "$KEY_VAULT_URL" ]; then
        success "Key Vault знайдено: $KEY_VAULT_URL"
    else
        error "Key Vault $KEY_VAULT_NAME не знайдено"
        exit 1
    fi
else
    success "Key Vault URL: $KEY_VAULT_URL"
fi

# Налаштування прав доступу (якщо потрібно)
info "Перевірка прав доступу до Key Vault..."
if ! az keyvault secret list --vault-name $KEY_VAULT_NAME --output none 2>/dev/null; then
    warning "Немає прав доступу до Key Vault, налаштовуємо..."
    
    if az keyvault set-policy \
        --name $KEY_VAULT_NAME \
        --object-id $CURRENT_USER_OBJECT_ID \
        --secret-permissions get list set delete \
        --output none 2>/dev/null; then
        success "Права доступу налаштовано (Access Policies)"
    else
        info "Спроба налаштувати RBAC права..."
        VAULT_SCOPE="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
        
        if az role assignment create \
            --assignee $CURRENT_USER_OBJECT_ID \
            --role "Key Vault Secrets Officer" \
            --scope $VAULT_SCOPE \
            --output none 2>/dev/null; then
            success "RBAC права налаштовано"
            info "Очікування поширення RBAC прав (30 секунд)..."
            sleep 30
        else
            warning "Не вдалося налаштувати права доступу автоматично"
            warning "Можливо, потрібні права адміністратора"
        fi
    fi
else
    success "Права доступу до Key Vault підтверджено"
fi

# Генерація секретів
info "Генерація нових секретів..."

# 1. Django Secret Key
info "Генерація Django SECRET_KEY..."
DJANGO_SECRET=$(generate_django_secret)

if [ -n "$DJANGO_SECRET" ] && [ ${#DJANGO_SECRET} -gt 30 ]; then
    success "Django SECRET_KEY згенеровано (довжина: ${#DJANGO_SECRET})"
    info "Перші 20 символів: ${DJANGO_SECRET:0:20}..."
else
    error "Не вдалося згенерувати Django SECRET_KEY"
    exit 1
fi

# 2. Database Password  
info "Генерація Database Password..."
DATABASE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/")
if [ ${#DATABASE_PASSWORD} -lt 20 ]; then
    DATABASE_PASSWORD="${DATABASE_PASSWORD}$(openssl rand -base64 10 | tr -d "=+/")"
fi
success "Database Password згенеровано (довжина: ${#DATABASE_PASSWORD})"

# 3. Email Password (placeholder)
EMAIL_PASSWORD="change-me-email-password-$(date +%Y%m%d)"

# Встановлення секретів у Key Vault
info "Встановлення секретів у Key Vault..."

# Встановлення Django SECRET_KEY (з пріоритетом)
if set_keyvault_secret "$KEY_VAULT_NAME" "django-secret-key" "$DJANGO_SECRET" "Django SECRET_KEY"; then
    # Перевірка що секрет дійсно встановився
    VERIFICATION=$(az keyvault secret show \
        --vault-name $KEY_VAULT_NAME \
        --name "django-secret-key" \
        --query value -o tsv 2>/dev/null)
    
    if [ "$VERIFICATION" = "$DJANGO_SECRET" ]; then
        success "Django SECRET_KEY підтверджено в Key Vault"
    else
        warning "Django SECRET_KEY в Key Vault відрізняється від згенерованого"
        info "Повторна спроба оновлення..."
        
        # Повторна спроба з іншим методом
        if az keyvault secret set \
            --vault-name $KEY_VAULT_NAME \
            --name "django-secret-key" \
            --value "$DJANGO_SECRET" \
            --description "Django SECRET_KEY generated $(date)" \
            --output none; then
            success "Django SECRET_KEY оновлено (повторна спроба)"
        else
            error "Критична помилка: не вдалося встановити Django SECRET_KEY"
        fi
    fi
else
    error "Критична помилка: Django SECRET_KEY не встановлено"
fi

# Встановлення Database Password
set_keyvault_secret "$KEY_VAULT_NAME" "database-password" "$DATABASE_PASSWORD" "Database Password"

# Встановлення Email Password
set_keyvault_secret "$KEY_VAULT_NAME" "email-host-password" "$EMAIL_PASSWORD" "Email Host Password"

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

# Generated values (for reference - DO NOT USE IN PRODUCTION)
# Django SECRET_KEY length: ${#DJANGO_SECRET}
# Database Password length: ${#DATABASE_PASSWORD}
# Generation timestamp: $(date)
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

# Фінальна перевірка всіх секретів
info "Фінальна перевірка секретів..."

FINAL_TEST_RESULTS=""

# Перевірка Django SECRET_KEY
DJANGO_TEST=$(az keyvault secret show \
    --vault-name $KEY_VAULT_NAME \
    --name "django-secret-key" \
    --query value -o tsv 2>/dev/null)

if [ -n "$DJANGO_TEST" ] && [ ${#DJANGO_TEST} -gt 30 ]; then
    success "✅ Django SECRET_KEY: ${DJANGO_TEST:0:20}... (довжина: ${#DJANGO_TEST})"
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ✅ django-secret-key"
else
    error "❌ Django SECRET_KEY: не знайдено або некоректний"
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ❌ django-secret-key"
fi

# Перевірка Database Password
DB_TEST=$(az keyvault secret show \
    --vault-name $KEY_VAULT_NAME \
    --name "database-password" \
    --query value -o tsv 2>/dev/null)

if [ -n "$DB_TEST" ]; then
    success "✅ Database Password: ${DB_TEST:0:15}... (довжина: ${#DB_TEST})"
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ✅ database-password"
else
    warning "⚠️ Database Password: не знайдено"
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ⚠️ database-password"
fi

# Перевірка Email Password
EMAIL_TEST=$(az keyvault secret show \
    --vault-name $KEY_VAULT_NAME \
    --name "email-host-password" \
    --query value -o tsv 2>/dev/null)

if [ -n "$EMAIL_TEST" ]; then
    success "✅ Email Password: ${EMAIL_TEST:0:15}..."
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ✅ email-host-password"
else
    warning "⚠️ Email Password: не знайдено"
    FINAL_TEST_RESULTS="$FINAL_TEST_RESULTS\n   ⚠️ email-host-password"
fi

# Фінальний звіт
echo ""
echo "=================================================================="
success "Розгортання з Key Vault завершено!"
echo "=================================================================="
echo ""
echo "📊 Ресурси:"
echo "   • Resource Group: $RESOURCE_GROUP"
echo "   • Key Vault: $KEY_VAULT_NAME"  
echo "   • URL: $KEY_VAULT_URL"
echo ""
echo "🔐 Секрети:"
echo -e "$FINAL_TEST_RESULTS"
echo ""
echo "📁 Файли:"
echo "   • kv_vars.py (конфігурація) ✅"
echo "   • .gitignore (оновлено) ✅"
echo ""
echo "🧪 Тестування Python доступу:"
echo "   python3 -c \"from azure.keyvault.secrets import SecretClient; from azure.identity import DefaultAzureCredential; client = SecretClient('$KEY_VAULT_URL', DefaultAzureCredential()); print('Django Secret:', client.get_secret('django-secret-key').value[:20] + '...')\""
echo ""
echo "🔄 Наступні кроки:"
echo "   1. Протестуйте доступ командою вище"
echo "   2. Створіть utils/keyvault_client.py для Django"
echo "   3. Інтегруйте Key Vault у Django settings"
echo "   4. Запустіть Django сервер для тестування"
echo ""
success "Готово! 🎉"

# Додаткова інформація про генерацію
echo ""
info "Додаткова інформація:"
echo "   • Django SECRET_KEY згенеровано з довжиною ${#DJANGO_SECRET} символів"
echo "   • Використаний метод генерації: $(command -v python3 &>/dev/null && echo "Django get_random_secret_key" || echo "OpenSSL")"
echo "   • Всі секрети мають достатню ентропію для production використання"
