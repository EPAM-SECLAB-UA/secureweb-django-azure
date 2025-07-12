#!/bin/bash
# scripts/add-comprehensive-secrets.sh
# Автоматизоване додавання всіх секретів до Azure Key Vault

# Відключаємо автоматичний exit при помилках
set +e

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
KEY_VAULT_NAME="${1:-django-app-dev-kv}"
ENVIRONMENT="${2:-dev}"
VERBOSE="${3:-false}"

# Лічильники
TOTAL_SECRETS=0
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

echo "🔐 Додавання повного набору секретів до Key Vault"
echo "📍 Key Vault: $KEY_VAULT_NAME"
echo "🌍 Середовище: $ENVIRONMENT"
echo ""

# Перевірка доступу до Key Vault
info "Перевірка доступу до Key Vault..."
az keyvault show --name "$KEY_VAULT_NAME" --output none 2>/dev/null
if [ $? -ne 0 ]; then
    error "Key Vault '$KEY_VAULT_NAME' не знайдено або немає доступу"
    exit 1
fi
success "Доступ до Key Vault підтверджено"

# Функція для додавання секрету
add_secret() {
    local category="$1"
    local name="$2"
    local value="$3"
    local description="$4"
    local overwrite="${5:-false}"
    
    ((TOTAL_SECRETS++))
    
    # Перевірка на пусте значення
    if [[ -z "$value" ]]; then
        warning "[$category] $name: пусте значення, пропускаємо"
        ((SKIPPED_COUNT++))
        return 0
    fi
    
    # Перевірка чи секрет вже існує
    if [ "$overwrite" = "false" ]; then
        az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "$name" --output none 2>/dev/null
        if [ $? -eq 0 ]; then
            if [ "$VERBOSE" = "true" ]; then
                warning "[$category] $name вже існує, пропускаємо"
            fi
            ((SKIPPED_COUNT++))
            return 0
        fi
    fi
    
    if [ "$VERBOSE" = "true" ]; then
        info "[$category] Додавання: $name"
    fi
    
    # Додавання секрету
    az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "$name" \
        --value "$value" \
        --description "$description" \
        --tags category="$category" environment="$ENVIRONMENT" \
        --output none 2>/dev/null
    
    if [ $? -eq 0 ]; then
        if [ "$VERBOSE" = "true" ]; then
            success "   ✅ $name"
        fi
        ((SUCCESS_COUNT++))
    else
        if [ "$VERBOSE" = "true" ]; then
            error "   ❌ $name"
        fi
        ((FAILED_COUNT++))
    fi
}

# Функції для генерації
generate_password() {
    local length="${1:-32}"
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 "$length" 2>/dev/null | tr -d "=+/\n" | head -c "$length"
    else
        date +%s | sha256sum 2>/dev/null | head -c "$length" || echo "password$RANDOM$RANDOM"
    fi
}

generate_hex_token() {
    local length="${1:-32}"
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex "$length" 2>/dev/null
    else
        printf '%s' $(date +%s)$(($RANDOM * $RANDOM)) | sha256sum 2>/dev/null | head -c "$((length * 2))" || printf '%064s' | tr ' ' '0'
    fi
}

generate_django_secret() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' 2>/dev/null || generate_password 50
    else
        generate_password 50
    fi
}

echo "🏗️ Додавання базових Django секретів..."

# 1. Базові Django секрети (крім існуючих)
DEBUG_VALUE="false"
if [ "$ENVIRONMENT" = "dev" ]; then
    DEBUG_VALUE="true"
fi

add_secret "django-core" "django-debug-$ENVIRONMENT" "$DEBUG_VALUE" "Django DEBUG для $ENVIRONMENT"
add_secret "django-core" "django-allowed-hosts" "localhost,127.0.0.1,*.azurewebsites.net,*.herokuapp.com" "Django ALLOWED_HOSTS"

echo ""
echo "🗄️ Додавання секретів бази даних..."

# 2. База даних PostgreSQL
POSTGRES_PASSWORD=$(generate_password 32)
POSTGRES_HOST="django-app-${ENVIRONMENT}-postgres.postgres.database.azure.com"
DATABASE_URL="postgresql://dbadmin:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/django_${ENVIRONMENT}?sslmode=require"

add_secret "database" "postgres-host" "$POSTGRES_HOST" "PostgreSQL host для $ENVIRONMENT"
add_secret "database" "postgres-port" "5432" "PostgreSQL port"
add_secret "database" "postgres-database" "django_${ENVIRONMENT}" "PostgreSQL database name"
add_secret "database" "postgres-username" "dbadmin" "PostgreSQL username"
add_secret "database" "database-url" "$DATABASE_URL" "Повний PostgreSQL connection string"

# Backup credentials
add_secret "database" "postgres-backup-username" "backup_user" "PostgreSQL backup user"
add_secret "database" "postgres-backup-password" "$(generate_password 32)" "PostgreSQL backup password"

# Redis
REDIS_PASSWORD=$(generate_hex_token 16)
add_secret "database" "redis-url" "rediss://django-app-${ENVIRONMENT}-redis.redis.cache.windows.net:6380" "Redis URL"
add_secret "database" "redis-password" "$REDIS_PASSWORD" "Redis access key"

echo ""
echo "📧 Додавання email секретів..."

# 3. Email та повідомлення
add_secret "email" "email-host" "smtp.gmail.com" "SMTP host"
add_secret "email" "email-port" "587" "SMTP port"
add_secret "email" "email-host-user" "your-app@gmail.com" "SMTP username (ЗМІНІТЬ!)"
add_secret "email" "default-from-email" "Django App <noreply@yourapp.com>" "Default from email"

# SendGrid
add_secret "email" "sendgrid-api-key" "SG.your-sendgrid-api-key" "SendGrid API key (ЗМІНІТЬ!)"
add_secret "email" "sendgrid-from-email" "noreply@yourapp.com" "SendGrid from email"

echo ""
echo "🔌 Додавання API інтеграцій..."

# 4. API інтеграції
add_secret "api" "openai-api-key" "sk-your-openai-api-key" "OpenAI API key (ЗМІНІТЬ!)"
add_secret "api" "google-api-key" "AIzaSyYour-Google-API-Key" "Google API key (ЗМІНІТЬ!)"
add_secret "api" "google-maps-api-key" "AIzaSyYour-Google-Maps-Key" "Google Maps API key (ЗМІНІТЬ!)"
add_secret "api" "google-analytics-id" "G-XXXXXXXXXX" "Google Analytics ID (ЗМІНІТЬ!)"

echo ""
echo "🛡️ Додавання секретів безпеки..."

# 5. Безпека та автентифікація
JWT_SECRET=$(generate_password 64)
JWT_REFRESH_SECRET=$(generate_password 64)
CSRF_SECRET=$(generate_hex_token 16)

add_secret "security" "jwt-secret-key" "$JWT_SECRET" "JWT secret key"
add_secret "security" "jwt-refresh-secret" "$JWT_REFRESH_SECRET" "JWT refresh secret"
add_secret "security" "csrf-cookie-secret" "$CSRF_SECRET" "CSRF cookie secret"

# OAuth2 Providers
add_secret "security" "google-oauth-client-id" "your-google-client-id.apps.googleusercontent.com" "Google OAuth Client ID (ЗМІНІТЬ!)"
add_secret "security" "google-oauth-client-secret" "GOCSPX-your-google-client-secret" "Google OAuth Client Secret (ЗМІНІТЬ!)"

echo ""
echo "☁️ Додавання Azure сервісів..."

# 6. Azure сервіси
STORAGE_ACCOUNT_NAME="djangoapp${ENVIRONMENT}storage"
add_secret "azure" "azure-storage-account-name" "$STORAGE_ACCOUNT_NAME" "Azure Storage Account name"

# Спроба отримати справжній ключ storage account
STORAGE_KEY=$(az storage account keys list --account-name "$STORAGE_ACCOUNT_NAME" --query "[0].value" -o tsv 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$STORAGE_KEY" ]; then
    add_secret "azure" "azure-storage-account-key" "$STORAGE_KEY" "Azure Storage Account key"
    CONNECTION_STRING=$(az storage account show-connection-string --name "$STORAGE_ACCOUNT_NAME" --query connectionString -o tsv 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$CONNECTION_STRING" ]; then
        add_secret "azure" "azure-storage-connection-string" "$CONNECTION_STRING" "Azure Storage connection string"
    fi
else
    warning "Storage Account '$STORAGE_ACCOUNT_NAME' не знайдено, додаємо placeholder"
    add_secret "azure" "azure-storage-account-key" "your-storage-account-key" "Azure Storage Account key (ЗМІНІТЬ!)"
    add_secret "azure" "azure-storage-connection-string" "DefaultEndpointsProtocol=https;AccountName=$STORAGE_ACCOUNT_NAME;AccountKey=your-key;EndpointSuffix=core.windows.net" "Azure Storage connection string (ЗМІНІТЬ!)"
fi

add_secret "azure" "azure-storage-container-media" "media" "Media files container"
add_secret "azure" "azure-storage-container-static" "static" "Static files container"

echo ""
echo "📊 Додавання моніторингу..."

# 7. Моніторинг та логування
add_secret "monitoring" "sentry-dsn" "https://your-sentry-dsn@sentry.io/project-id" "Sentry DSN (ЗМІНІТЬ!)"
add_secret "monitoring" "sentry-environment" "$ENVIRONMENT" "Sentry environment"

echo ""
echo "💳 Додавання платіжних секретів..."

# 8. Платежі та комерція
add_secret "payments" "stripe-publishable-key" "pk_test_your-stripe-publishable-key" "Stripe publishable key (ЗМІНІТЬ!)"
add_secret "payments" "stripe-secret-key" "sk_test_your-stripe-secret-key" "Stripe secret key (ЗМІНІТЬ!)"
add_secret "payments" "stripe-webhook-secret" "whsec_your-webhook-secret" "Stripe webhook secret (ЗМІНІТЬ!)"

echo ""
echo "🔧 Додавання DevOps конфігурації..."

# 9. DevOps та середовища
RATE_LIMIT_MINUTE="1000"
RATE_LIMIT_HOUR="10000"
ENV_COLOR="#28a745"

if [ "$ENVIRONMENT" != "dev" ]; then
    RATE_LIMIT_MINUTE="500"
    RATE_LIMIT_HOUR="5000"
    if [ "$ENVIRONMENT" = "staging" ]; then
        ENV_COLOR="#ffc107"
    else
        ENV_COLOR="#dc3545"
    fi
fi

add_secret "devops" "environment-name" "$ENVIRONMENT" "Environment name"
add_secret "devops" "environment-color" "$ENV_COLOR" "Environment color"
add_secret "devops" "app-version" "1.0.0" "Application version"
add_secret "devops" "rate-limit-per-minute" "$RATE_LIMIT_MINUTE" "Rate limit per minute"
add_secret "devops" "rate-limit-per-hour" "$RATE_LIMIT_HOUR" "Rate limit per hour"
add_secret "devops" "session-cookie-age" "1209600" "Session cookie age (2 weeks)"
add_secret "devops" "session-cookie-name" "django_session_$ENVIRONMENT" "Session cookie name"
add_secret "devops" "backup-encryption-key" "$(generate_password 32)" "Backup encryption key"
add_secret "devops" "health-check-token" "$(generate_hex_token 8)" "Health check token"
add_secret "devops" "admin-api-key" "$(generate_password 32)" "Admin API key"

# Фінальний звіт
echo ""
echo "=================================================================="
success "Додавання секретів завершено!"
echo "=================================================================="
echo ""
echo "📊 Статистика:"
echo "   • Всього секретів: $TOTAL_SECRETS"
echo "   • Успішно додано: $SUCCESS_COUNT"
echo "   • Пропущено (існують): $SKIPPED_COUNT"
echo "   • Помилок: $FAILED_COUNT"
echo ""

echo "🔍 Перегляд доданих секретів:"
az keyvault secret list --vault-name "$KEY_VAULT_NAME" --output table

echo ""
echo "⚠️ ВАЖЛИВО:"
echo "   • Оновіть всі секрети з міткою '(ЗМІНІТЬ!)' реальними значеннями"
echo "   • Никогда не використовуйте ці placeholder значення в production"
echo ""

echo "🔧 Команди для оновлення секретів:"
echo "   az keyvault secret set --vault-name '$KEY_VAULT_NAME' --name 'secret-name' --value 'new-value'"
echo ""

success "Готово! 🎉"
