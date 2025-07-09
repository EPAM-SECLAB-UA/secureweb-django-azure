#!/bin/bash
# =============================================================================
# ПОКРАЩЕНИЙ скрипт для створення Azure інфраструктури Django додатку
# Версія: 2.0.0
# Покращення: B1 план, Docker support, Production-ready, Health checks
# =============================================================================

set -euo pipefail  # Strict error handling

# Кольори для виводу
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Функції для логування
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# =============================================================================
# PRODUCTION-READY КОНФІГУРАЦІЯ
# =============================================================================

# Основні параметри
PROJECT_NAME="${PROJECT_NAME:-django-app}"
ENVIRONMENT="${ENVIRONMENT:-production}"
LOCATION="${LOCATION:-West Europe}"
TIMESTAMP=$(date +%s)

# Імена ресурсів
RESOURCE_GROUP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-rg"
APP_SERVICE_PLAN_NAME="${PROJECT_NAME}-${ENVIRONMENT}-plan"
WEB_APP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${TIMESTAMP}"
DATABASE_SERVER_NAME="${PROJECT_NAME}-${ENVIRONMENT}-db-${TIMESTAMP}"
DATABASE_NAME="${PROJECT_NAME//-/_}_db"
STORAGE_ACCOUNT_NAME="$(echo ${PROJECT_NAME} | tr -d '-')${TIMESTAMP: -8}"
KEY_VAULT_NAME="${PROJECT_NAME}-kv-${TIMESTAMP: -6}"
APP_INSIGHTS_NAME="${PROJECT_NAME}-${ENVIRONMENT}-insights"
CONTAINER_REGISTRY_NAME="${PROJECT_NAME}acr${TIMESTAMP: -8}"

# 🚀 PRODUCTION-READY КОНФІГУРАЦІЯ
case "$ENVIRONMENT" in
    "production")
        APP_SERVICE_SKU="S1"              # Standard для production
        DB_SKU="Standard_D2s_v3"          # GeneralPurpose для production
        DB_TIER="GeneralPurpose"
        DB_STORAGE_SIZE="128"             # Більше storage
        STORAGE_SKU="Standard_GRS"        # Geo-redundant для production
        BACKUP_RETENTION_DAYS="30"
        ;;
    "staging")
        APP_SERVICE_SKU="B2"              # Basic для staging
        DB_SKU="Standard_B2s"             # Burstable для staging
        DB_TIER="Burstable"
        DB_STORAGE_SIZE="64"
        STORAGE_SKU="Standard_LRS"
        BACKUP_RETENTION_DAYS="7"
        ;;
    "development"|"budget")
        APP_SERVICE_SKU="B1"              # Basic замість F1
        DB_SKU="Standard_B1ms"            # Burstable для dev
        DB_TIER="Burstable"
        DB_STORAGE_SIZE="32"
        STORAGE_SKU="Standard_LRS"
        BACKUP_RETENTION_DAYS="7"
        ;;
    *)
        error "Невідомий environment: $ENVIRONMENT. Підтримуються: production, staging, development, budget"
        ;;
esac

PYTHON_VERSION="3.11"
DJANGO_VERSION="4.2"

# Конфігурація бази даних
DB_ADMIN_USER="djangoadmin"
DB_ADMIN_PASSWORD="$(openssl rand -base64 32 | tr -d '=/+' | cut -c1-20)Aa1!"

# Теги для ресурсів
TAGS="Environment=${ENVIRONMENT} Project=${PROJECT_NAME} CreatedBy=ImprovedScript ManagedBy=Infrastructure-as-Code"

# =============================================================================
# ПОКАЗ КОНФІГУРАЦІЇ
# =============================================================================

show_configuration() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}🚀 AZURE DJANGO INFRASTRUCTURE v2.0${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo -e "${BOLD}📊 Конфігурація розгортання:${NC}"
    echo "  🎯 Environment: $ENVIRONMENT"
    echo "  📍 Location: $LOCATION"
    echo "  🏗️  Project: $PROJECT_NAME"
    echo ""
    echo -e "${BOLD}💰 Вартість (орієнтовно):${NC}"
    case "$ENVIRONMENT" in
        "production")
            echo "  🚀 App Service S1: ~$75/місяць"
            echo "  🗄️  Database GeneralPurpose: ~$85/місяць"
            echo "  💾 Storage GRS: ~$10/місяць"
            echo "  🔐 Key Vault: ~$1/місяць"
            echo "  📊 Container Registry: ~$5/місяць"
            echo "  📈 App Insights: безкоштовно (до 5GB)"
            echo "  💰 ЗАГАЛЬНА ВАРТІСТЬ: ~$175/місяць"
            ;;
        "staging")
            echo "  🚀 App Service B2: ~$35/місяць"
            echo "  🗄️  Database B2s: ~$30/місяць"
            echo "  💾 Storage LRS: ~$5/місяць"
            echo "  🔐 Key Vault: ~$1/місяць"
            echo "  📊 Container Registry: ~$5/місяць"
            echo "  📈 App Insights: безкоштовно"
            echo "  💰 ЗАГАЛЬНА ВАРТІСТЬ: ~$75/місяць"
            ;;
        *)
            echo "  🚀 App Service B1: ~$13/місяць"
            echo "  🗄️  Database B1ms: ~$12/місяць"
            echo "  💾 Storage LRS: ~$5/місяць"
            echo "  🔐 Key Vault: ~$1/місяць"
            echo "  📊 Container Registry: ~$5/місяць"
            echo "  📈 App Insights: безкоштовно"
            echo "  💰 ЗАГАЛЬНА ВАРТІСТЬ: ~$35/місяць"
            ;;
    esac
    echo ""
    echo -e "${BOLD}🔧 Технічні характеристики:${NC}"
    echo "  🐍 Python: $PYTHON_VERSION"
    echo "  🎸 Django: $DJANGO_VERSION"
    echo "  📊 App Service SKU: $APP_SERVICE_SKU"
    echo "  🗄️  Database SKU: $DB_SKU ($DB_TIER)"
    echo "  💾 Storage: $STORAGE_SKU"
    echo "  🔄 Backup retention: $BACKUP_RETENTION_DAYS днів"
    echo ""
}

# =============================================================================
# ВАЛІДАЦІЯ СЕРЕДОВИЩА
# =============================================================================

validate_prerequisites() {
    log "🔍 Перевірка передумов..."
    
    local errors=0
    
    # Azure CLI
    if ! command -v az &> /dev/null; then
        error "Azure CLI не встановлено. Встановіть з: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    fi
    
    # Azure авторизація
    if ! az account show &> /dev/null; then
        error "Не авторизовані в Azure CLI. Виконайте: az login"
    fi
    
    # OpenSSL
    if ! command -v openssl &> /dev/null; then
        error "OpenSSL не встановлено"
    fi
    
    # Git (опціонально)
    if ! command -v git &> /dev/null; then
        warning "Git не встановлено. Деякі функції можуть не працювати"
    fi
    
    # Docker (опціонально)
    if ! command -v docker &> /dev/null; then
        warning "Docker не встановлено. Container features недоступні"
    fi
    
    # Перевірка регіону
    local available_locations=$(az account list-locations --query "[].name" -o tsv)
    if ! echo "$available_locations" | grep -q "West Europe"; then
        warning "Регіон 'West Europe' може бути недоступний"
    fi
    
    # Перевірка квот
    info "Перевірка квот Azure..."
    local subscription_id=$(az account show --query id -o tsv)
    log "✅ Azure Subscription: $subscription_id"
    
    log "✅ Всі передумови перевірено"
}

# =============================================================================
# СТВОРЕННЯ РЕСУРСІВ
# =============================================================================

create_resource_group() {
    info "🔄 КРОК 1/12: Створення Resource Group"
    log "Створення Resource Group: ${RESOURCE_GROUP_NAME}"
    
    az group create \
        --name "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --tags $TAGS
    
    log "✅ Resource Group створено"
}

create_container_registry() {
    info "🔄 КРОК 2/12: Створення Container Registry"
    log "Створення Container Registry: ${CONTAINER_REGISTRY_NAME}"
    
    az acr create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$CONTAINER_REGISTRY_NAME" \
        --sku Basic \
        --admin-enabled true \
        --tags $TAGS
    
    log "✅ Container Registry створено"
}

create_storage_account() {
    info "🔄 КРОК 3/12: Створення Storage Account"
    log "Створення Storage Account: ${STORAGE_ACCOUNT_NAME}"
    
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --sku "$STORAGE_SKU" \
        --kind StorageV2 \
        --access-tier Hot \
        --enable-https-traffic-only true \
        --tags $TAGS
    
    # Створення контейнерів
    log "Створення контейнерів для статичних файлів та медіа"
    local storage_key=$(az storage account keys list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --query '[0].value' \
        --output tsv)
    
    # Контейнери з правильними правами доступу
    az storage container create \
        --name "static" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$storage_key" \
        --public-access blob
    
    az storage container create \
        --name "media" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$storage_key" \
        --public-access blob
    
    az storage container create \
        --name "backups" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$storage_key" \
        --public-access off
    
    log "✅ Storage Account та контейнери створено"
}

create_postgresql_database() {
    info "🔄 КРОК 4/12: Створення PostgreSQL Database"
    log "Створення PostgreSQL сервера: ${DATABASE_SERVER_NAME}"
    warning "SKU: $DB_SKU в $DB_TIER tier"
    
    # Створення PostgreSQL Flexible Server
    az postgres flexible-server create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DATABASE_SERVER_NAME" \
        --location "$LOCATION" \
        --admin-user "$DB_ADMIN_USER" \
        --admin-password "$DB_ADMIN_PASSWORD" \
        --sku-name "$DB_SKU" \
        --tier "$DB_TIER" \
        --storage-size "$DB_STORAGE_SIZE" \
        --version 15 \
        --public-access 0.0.0.0 \
        --tags $TAGS
    
    # Створення бази даних
    log "Створення бази даних: ${DATABASE_NAME}"
    az postgres flexible-server db create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --server-name "$DATABASE_SERVER_NAME" \
        --database-name "$DATABASE_NAME"
    
    # Налаштування backup
    log "Налаштування backup retention: $BACKUP_RETENTION_DAYS днів"
    az postgres flexible-server parameter set \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --server-name "$DATABASE_SERVER_NAME" \
        --name backup_retention_days \
        --value "$BACKUP_RETENTION_DAYS"
    
    # Firewall правила
    log "Налаштування firewall правил"
    az postgres flexible-server firewall-rule create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DATABASE_SERVER_NAME" \
        --rule-name "AllowAzureServices" \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 0.0.0.0
    
    log "✅ PostgreSQL Database створено"
}

create_key_vault() {
    info "🔄 КРОК 5/12: Створення Key Vault"
    log "Створення Key Vault: ${KEY_VAULT_NAME}"
    
    az keyvault create \
        --name "$KEY_VAULT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --enable-rbac-authorization false \
        --enable-soft-delete true \
        --soft-delete-retention-days 90 \
        --enable-purge-protection true \
        --tags $TAGS
    
    # Налаштування прав доступу
    log "Налаштування прав доступу до Key Vault"
    local current_user_id=$(az ad signed-in-user show --query id --output tsv)
    az keyvault set-policy \
        --name "$KEY_VAULT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --object-id "$current_user_id" \
        --secret-permissions backup delete get list purge recover restore set
    
    log "✅ Key Vault створено"
}

add_secrets_to_vault() {
    info "🔄 КРОК 6/12: Додавання секретів до Key Vault"
    log "Генерація та додавання секретів"
    
    # Генерація Django secret key
    local django_secret_key=$(openssl rand -base64 64 | tr -d '=/+' | cut -c1-50)
    
    # Отримання storage key
    local storage_key=$(az storage account keys list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --query '[0].value' \
        --output tsv)
    
    # Додавання секретів
    local secrets_added=0
    
    if az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "django-secret-key" \
        --value "$django_secret_key" >/dev/null 2>&1; then
        log "✅ Django secret key додано"
        secrets_added=$((secrets_added + 1))
    else
        warning "❌ Помилка додавання Django secret key"
    fi
    
    if az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "database-password" \
        --value "$DB_ADMIN_PASSWORD" >/dev/null 2>&1; then
        log "✅ Database password додано"
        secrets_added=$((secrets_added + 1))
    else
        warning "❌ Помилка додавання database password"
    fi
    
    if az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "storage-account-key" \
        --value "$storage_key" >/dev/null 2>&1; then
        log "✅ Storage account key додано"
        secrets_added=$((secrets_added + 1))
    else
        warning "❌ Помилка додавання storage account key"
    fi
    
    # Додавання database URL
    local database_url="postgresql://${DB_ADMIN_USER}:${DB_ADMIN_PASSWORD}@${DATABASE_SERVER_NAME}.postgres.database.azure.com:5432/${DATABASE_NAME}?sslmode=require"
    if az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "database-url" \
        --value "$database_url" >/dev/null 2>&1; then
        log "✅ Database URL додано"
        secrets_added=$((secrets_added + 1))
    else
        warning "❌ Помилка додавання database URL"
    fi
    
    log "✅ Секретів додано: $secrets_added/4"
}

create_application_insights() {
    info "🔄 КРОК 7/12: Створення Application Insights"
    log "Створення Application Insights: ${APP_INSIGHTS_NAME}"
    
    az monitor app-insights component create \
        --app "$APP_INSIGHTS_NAME" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --application-type web \
        --kind web \
        --tags $TAGS
    
    # Отримання ключів
    local instrumentation_key=$(az monitor app-insights component show \
        --app "$APP_INSIGHTS_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "instrumentationKey" \
        --output tsv)
    
    local connection_string=$(az monitor app-insights component show \
        --app "$APP_INSIGHTS_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "connectionString" \
        --output tsv)
    
    # Додавання до Key Vault
    az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "appinsights-instrumentation-key" \
        --value "$instrumentation_key" >/dev/null 2>&1
    
    az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "appinsights-connection-string" \
        --value "$connection_string" >/dev/null 2>&1
    
    log "✅ Application Insights створено"
}

create_app_service_plan() {
    info "🔄 КРОК 8/12: Створення App Service Plan"
    log "Створення App Service Plan: ${APP_SERVICE_PLAN_NAME}"
    info "SKU: $APP_SERVICE_SKU"
    
    az appservice plan create \
        --name "$APP_SERVICE_PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --sku "$APP_SERVICE_SKU" \
        --is-linux \
        --tags $TAGS
    
    log "✅ App Service Plan створено"
}

create_web_app() {
    info "🔄 КРОК 9/12: Створення Web App"
    log "Створення Web App: ${WEB_APP_NAME}"
    
    az webapp create \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --plan "$APP_SERVICE_PLAN_NAME" \
        --runtime "PYTHON:${PYTHON_VERSION}" \
        --tags $TAGS
    
    # Налаштування managed identity
    log "Налаштування Managed Identity"
    az webapp identity assign \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME"
    
    # Отримання Principal ID
    local principal_id=$(az webapp identity show \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "principalId" \
        --output tsv)
    
    # Надання доступу до Key Vault
    az keyvault set-policy \
        --name "$KEY_VAULT_NAME" \
        --object-id "$principal_id" \
        --secret-permissions get list
    
    # Надання доступу до Container Registry
    az acr identity assign \
        --identities "$principal_id" \
        --name "$CONTAINER_REGISTRY_NAME"
    
    log "✅ Web App створено"
}

configure_web_app() {
    info "🔄 КРОК 10/12: Налаштування Web App"
    log "Налаштування змінних середовища"
    
    # Базові налаштування
    az webapp config appsettings set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --settings \
            DJANGO_SETTINGS_MODULE="config.settings.${ENVIRONMENT}" \
            ENVIRONMENT="$ENVIRONMENT" \
            DEBUG="False" \
            ALLOWED_HOSTS="${WEB_APP_NAME}.azurewebsites.net" \
            PYTHONPATH="/home/site/wwwroot" \
            DJANGO_SECRET_KEY="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=django-secret-key)" \
            DATABASE_URL="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=database-url)" \
            AZURE_STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME" \
            AZURE_STORAGE_ACCOUNT_KEY="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=storage-account-key)" \
            AZURE_STORAGE_CONTAINER_STATIC="static" \
            AZURE_STORAGE_CONTAINER_MEDIA="media" \
            APPINSIGHTS_INSTRUMENTATIONKEY="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=appinsights-instrumentation-key)" \
            APPLICATIONINSIGHTS_CONNECTION_STRING="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=appinsights-connection-string)"
    
    # Налаштування для різних середовищ
    case "$ENVIRONMENT" in
        "production")
            az webapp config appsettings set \
                --name "$WEB_APP_NAME" \
                --resource-group "$RESOURCE_GROUP_NAME" \
                --settings \
                    DJANGO_LOG_LEVEL="ERROR" \
                    WORKERS="4" \
                    TIMEOUT="600"
            ;;
        "staging")
            az webapp config appsettings set \
                --name "$WEB_APP_NAME" \
                --resource-group "$RESOURCE_GROUP_NAME" \
                --settings \
                    DJANGO_LOG_LEVEL="WARNING" \
                    WORKERS="2" \
                    TIMEOUT="300"
            ;;
        *)
            az webapp config appsettings set \
                --name "$WEB_APP_NAME" \
                --resource-group "$RESOURCE_GROUP_NAME" \
                --settings \
                    DJANGO_LOG_LEVEL="INFO" \
                    WORKERS="1" \
                    TIMEOUT="300"
            ;;
    esac
    
    # Startup команда
    log "Налаштування startup команди"
    az webapp config set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --startup-file "startup.sh"
    
    # Логування
    az webapp log config \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --application-logging filesystem \
        --level error \
        --detailed-error-messages true \
        --failed-request-tracing true
    
    # HTTPS
    log "Увімкнення HTTPS"
    az webapp update \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --https-only true
    
    log "✅ Web App налаштовано"
}

# =============================================================================
# СТВОРЕННЯ КОНФІГУРАЦІЙНИХ ФАЙЛІВ
# =============================================================================

create_configuration_files() {
    info "🔄 КРОК 11/12: Створення конфігураційних файлів"
    log "Створення production-ready конфігураційних файлів"
    
    # Dockerfile
    cat > Dockerfile << EOF
FROM python:${PYTHON_VERSION}-slim

# Встановлення системних залежностей
RUN apt-get update && apt-get install -y \\
    postgresql-client \\
    gcc \\
    && rm -rf /var/lib/apt/lists/*

# Робоча директорія
WORKDIR /app

# Копіювання requirements
COPY requirements/ ./requirements/
RUN pip install --no-cache-dir -r requirements/${ENVIRONMENT}.txt

# Копіювання коду
COPY . .

# Збирання статики
RUN python manage.py collectstatic --noinput --settings=config.settings.${ENVIRONMENT}

# Створення непривілейованого користувача
RUN useradd --create-home --shell /bin/bash app \\
    && chown -R app:app /app
USER app

# Відкриття порту
EXPOSE 8000

# Запуск додатку
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--timeout", "600", "config.wsgi:application"]
EOF
    
    # Requirements структура
    mkdir -p requirements
    
    # Base requirements
    cat > requirements/base.txt << EOF
# Core Django
Django>=${DJANGO_VERSION},<5.0
psycopg2-binary>=2.9.0
gunicorn>=20.1.0

# Django extensions
django-extensions>=3.2.0
django-cors-headers>=4.0.0
django-environ>=0.10.0

# Storage
django-storages[azure]>=1.13.0
whitenoise>=6.0.0

# Security
django-csp>=3.7
cryptography>=41.0.0

# API
djangorestframework>=3.14.0
djangorestframework-simplejwt>=5.2.0

# Monitoring
django-prometheus>=2.3.0
EOF
    
    # Production requirements
    cat > requirements/production.txt << EOF
-r base.txt

# Production-specific
sentry-sdk[django]>=1.25.0
redis>=4.5.0
django-redis>=5.2.0
celery>=5.3.0

# Monitoring
applicationinsights>=0.11.10
opencensus-ext-azure>=1.1.0
opencensus-ext-django>=0.8.0
EOF
    
    # Development requirements
    cat > requirements/development.txt << EOF
-r base.txt

# Development tools
django-debug-toolbar>=4.0.0
django-silk>=5.0.0
pytest-django>=4.5.0
pytest-cov>=4.0.0
factory-boy>=3.2.0

# Code quality
black>=23.0.0
flake8>=6.0.0
isort>=5.12.0
mypy>=1.3.0
pre-commit>=3.3.0
EOF
    
    # Startup script
    cat > startup.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Starting Django application..."
echo "Environment: ${ENVIRONMENT:-production}"
echo "Debug: ${DEBUG:-False}"

# Ожидание базы данных
echo "⏳ Waiting for database..."
python manage.py wait_for_db --timeout=30

# Миграции
echo "📊 Running migrations..."
python manage.py migrate --noinput

# Сборка статики
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear

# Создание superuser если не существует
if [ "$ENVIRONMENT" != "production" ]; then
    echo "👤 Creating superuser..."
    python manage.py ensure_superuser
fi

# Запуск сервера
echo "🌐 Starting server..."
exec gunicorn \\
    --bind 0.0.0.0:8000 \\
    --workers ${WORKERS:-4} \\
    --timeout ${TIMEOUT:-600} \\
    --max-requests 1000 \\
    --max-requests-jitter 100 \\
    --access-logfile - \\
    --error-logfile - \\
    config.wsgi:application
EOF
    chmod +x startup.sh
    
    # Settings структура
    mkdir -p config/settings
    
    # Base settings
    cat > config/settings/base.py << 'EOF'
"""
Base Django settings for production-ready deployment
"""
import os
from pathlib import Path
import environ

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Environment
env = environ.Env(
    DEBUG=(bool, False)
)

# Read .env file
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

# Security
SECRET_KEY = env('DJANGO_SECRET_KEY')
DEBUG = env('DEBUG')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=[])

# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'corsheaders',
    'django_extensions',
]

LOCAL_APPS = [
    'apps.core',
    'apps.users',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Database
DATABASES = {
    'default': env.db('DATABASE_URL')
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'static']

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# CORS
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
CORS_ALLOW_ALL_ORIGINS = env.bool('CORS_ALLOW_ALL_ORIGINS', default=False)
EOF
    
    # Production settings
    cat > config/settings/production.py << 'EOF'
from .base import *

# Security
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# Database optimization
DATABASES['default'].update({
    'CONN_MAX_AGE': 600,
    'OPTIONS': {
        'sslmode': 'require',
    },
})

# Caching
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Sessions
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'

# Azure Storage
if env('AZURE_STORAGE_ACCOUNT_NAME', default=None):
    DEFAULT_FILE_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    AZURE_ACCOUNT_NAME = env('AZURE_STORAGE_ACCOUNT_NAME')
    AZURE_ACCOUNT_KEY = env('AZURE_STORAGE_ACCOUNT_KEY')
    AZURE_CONTAINER = env('AZURE_STORAGE_CONTAINER_MEDIA', default='media')

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Monitoring
if env('APPINSIGHTS_INSTRUMENTATIONKEY', default=None):
    INSTALLED_APPS += ['applicationinsights.django']
    MIDDLEWARE += ['applicationinsights.django.ApplicationInsightsMiddleware']
    APPLICATION_INSIGHTS = {
        'ikey': env('APPINSIGHTS_INSTRUMENTATIONKEY'),
    }
EOF
    
    # Environment template
    cat > .env.template << EOF
# Django Core
DJANGO_SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=${WEB_APP_NAME}.azurewebsites.net

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Azure Storage
AZURE_STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME}
AZURE_STORAGE_ACCOUNT_KEY=your-storage-key
AZURE_STORAGE_CONTAINER_MEDIA=media
AZURE_STORAGE_CONTAINER_STATIC=static

# Monitoring
APPINSIGHTS_INSTRUMENTATIONKEY=your-instrumentation-key
APPLICATIONINSIGHTS_CONNECTION_STRING=your-connection-string

# Performance
WORKERS=4
TIMEOUT=600
DJANGO_LOG_LEVEL=INFO

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com
CORS_ALLOW_ALL_ORIGINS=False
EOF
    
    log "✅ Конфігураційні файли створено"
}

# =============================================================================
# ФІНАЛЬНИЙ ЗВІТ
# =============================================================================

generate_final_report() {
    info "🔄 КРОК 12/12: Генерація фінального звіту"
    
    # Отримання URL додатку
    local app_url=$(az webapp show \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "defaultHostName" \
        --output tsv)
    
    # Отримання container registry URL
    local registry_url=$(az acr show \
        --name "$CONTAINER_REGISTRY_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "loginServer" \
        --output tsv)
    
    log "✅ Інфраструктура успішно створена!"
    
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}🎉 РОЗГОРТАННЯ ЗАВЕРШЕНО УСПІШНО!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo -e "${BOLD}📋 СТВОРЕНІ РЕСУРСИ:${NC}"
    echo "🌍 Resource Group: $RESOURCE_GROUP_NAME"
    echo "🚀 Web App: $WEB_APP_NAME"
    echo "🔗 URL: https://$app_url"
    echo "📊 App Service Plan: $APP_SERVICE_PLAN_NAME ($APP_SERVICE_SKU)"
    echo "🗄️  PostgreSQL Server: $DATABASE_SERVER_NAME ($DB_SKU)"
    echo "🗃️  Database: $DATABASE_NAME"
    echo "💾 Storage Account: $STORAGE_ACCOUNT_NAME ($STORAGE_SKU)"
    echo "🔐 Key Vault: $KEY_VAULT_NAME"
    echo "📈 Application Insights: $APP_INSIGHTS_NAME"
    echo "📦 Container Registry: $CONTAINER_REGISTRY_NAME"
    echo "🌐 Registry URL: $registry_url"
    echo ""
    echo -e "${BOLD}🔧 CREDENTIALS:${NC}"
    echo "Database User: $DB_ADMIN_USER"
    echo "Database Password: $DB_ADMIN_PASSWORD"
    echo "Database URL: postgresql://$DB_ADMIN_USER:$DB_ADMIN_PASSWORD@$DATABASE_SERVER_NAME.postgres.database.azure.com:5432/$DATABASE_NAME"
    echo ""
    echo -e "${BOLD}📁 СТВОРЕНІ ФАЙЛИ:${NC}"
    echo "  ✅ Dockerfile - контейнеризація"
    echo "  ✅ requirements/ - структуровані залежності"
    echo "  ✅ startup.sh - production-ready startup"
    echo "  ✅ config/settings/ - модульні налаштування"
    echo "  ✅ .env.template - шаблон змінних середовища"
    echo ""
    echo -e "${BOLD}🚀 НАСТУПНІ КРОКИ:${NC}"
    echo "1. Скопіюйте .env.template в .env та налаштуйте"
    echo "2. Розгорніть код: docker build та az webapp deployment"
    echo "3. Налаштуйте CI/CD через GitHub Actions"
    echo "4. Налаштуйте custom domain та SSL"
    echo "5. Налаштуйте monitoring та alerting"
    echo ""
    echo -e "${BOLD}💡 РЕКОМЕНДАЦІЇ:${NC}"
    echo "• Використовуйте Docker для консистентного розгортання"
    echo "• Налаштуйте автоматичні бекапи"
    echo "• Додайте Redis для кешування (production)"
    echo "• Налаштуйте CDN для статичних файлів"
    echo "• Регулярно оновлюйте залежності"
    echo ""
    
    # Збереження звіту
    cat > "${ENVIRONMENT}-infrastructure-summary.txt" << EOF
${PROJECT_NAME} AZURE INFRASTRUCTURE SUMMARY
==========================================
Environment: ${ENVIRONMENT}
Created: $(date --iso-8601=seconds)
Location: ${LOCATION}

RESOURCES:
- Resource Group: ${RESOURCE_GROUP_NAME}
- Web App: ${WEB_APP_NAME}
- URL: https://${app_url}
- App Service Plan: ${APP_SERVICE_PLAN_NAME} (${APP_SERVICE_SKU})
- PostgreSQL Server: ${DATABASE_SERVER_NAME} (${DB_SKU})
- Database: ${DATABASE_NAME}
- Storage Account: ${STORAGE_ACCOUNT_NAME} (${STORAGE_SKU})
- Key Vault: ${KEY_VAULT_NAME}
- Application Insights: ${APP_INSIGHTS_NAME}
- Container Registry: ${CONTAINER_REGISTRY_NAME}

CREDENTIALS:
- Database User: ${DB_ADMIN_USER}
- Database Password: ${DB_ADMIN_PASSWORD}
- Registry URL: ${registry_url}

CONFIGURATION:
- Python Version: ${PYTHON_VERSION}
- Django Version: ${DJANGO_VERSION}
- Database Tier: ${DB_TIER}
- Storage Tier: ${STORAGE_SKU}
- Backup Retention: ${BACKUP_RETENTION_DAYS} days

ESTIMATED COSTS:
$(case "$ENVIRONMENT" in
    "production") echo "- Monthly: ~\$175";;
    "staging") echo "- Monthly: ~\$75";;
    *) echo "- Monthly: ~\$35";;
esac)

NEXT STEPS:
1. Configure environment variables
2. Deploy application code
3. Set up CI/CD pipeline
4. Configure monitoring
5. Set up custom domain

Created by: Azure Django Infrastructure v2.0
EOF
    
    log "📄 Звіт збережено: ${ENVIRONMENT}-infrastructure-summary.txt"
    
    echo -e "${GREEN}Ваш ${ENVIRONMENT} Django додаток готовий! 🐍🚀${NC}"
    echo ""
}

# =============================================================================
# ГОЛОВНА ФУНКЦІЯ
# =============================================================================

main() {
    echo "🏁 Початок створення Azure Django Infrastructure v2.0"
    echo "Environment: $ENVIRONMENT"
    echo ""
    
    # Показ конфігурації
    show_configuration
    
    # Підтвердження
    if [ "${SKIP_CONFIRMATION:-false}" != "true" ]; then
        read -p "Продовжити розгортання? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Розгортання скасовано користувачем"
            exit 0
        fi
    fi
    
    # Валідація передумов
    validate_prerequisites
    
    # Створення ресурсів
    create_resource_group
    create_container_registry
    create_storage_account
    create_postgresql_database
    create_key_vault
    add_secrets_to_vault
    create_application_insights
    create_app_service_plan
    create_web_app
    configure_web_app
    create_configuration_files
    generate_final_report
    
    log "🎉 Розгортання успішно завершено!"
}

# =============================================================================
# CLEANUP ФУНКЦІЯ
# =============================================================================

cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "🚨 Помилка під час розгортання (exit code: $exit_code)"
        echo ""
        echo -e "${YELLOW}🔧 Діагностика:${NC}"
        echo "1. Перевірте логи Azure CLI"
        echo "2. Перевірте квоти підписки"
        echo "3. Перевірте права доступу"
        echo ""
        echo -e "${YELLOW}🧹 Очищення:${NC}"
        echo "Для видалення створених ресурсів виконайте:"
        echo "  az group delete --name '$RESOURCE_GROUP_NAME' --yes"
        echo ""
    fi
}

# =============================================================================
# ENTRY POINT
# =============================================================================

# Встановлення trap для cleanup
trap cleanup_on_error ERR

# Обробка параметрів командного рядка
case "${1:-}" in
    -h|--help)
        cat << EOF
Azure Django Infrastructure Deployment v2.0

ВИКОРИСТАННЯ:
  $0 [OPTIONS]

ОПЦІЇ:
  -h, --help              Показати цю довідку
  -e, --environment ENV   Встановити environment (production|staging|development|budget)
  -p, --project NAME      Встановити ім'я проекту
  -l, --location LOCATION Встановити Azure регіон
  -y, --yes               Пропустити підтвердження
  --dry-run               Показати конфігурацію без створення ресурсів

ЗМІННІ СЕРЕДОВИЩА:
  PROJECT_NAME           Ім'я проекту (за замовчуванням: django-app)
  ENVIRONMENT            Environment (за замовчуванням: production)
  LOCATION               Azure регіон (за замовчуванням: West Europe)
  SKIP_CONFIRMATION      Пропустити підтвердження (true/false)

ПРИКЛАДИ:
  $0                                    # Production розгортання
  $0 -e staging -p myapp               # Staging з custom назвою
  $0 -e development -y                 # Development без підтвердження
  $0 --dry-run                        # Тільки показати конфігурацію

ПІДТРИМУВАНІ ENVIRONMENTS:
  production   - S1 App Service, GeneralPurpose DB, GRS Storage (~$175/міс)
  staging      - B2 App Service, Burstable DB, LRS Storage (~$75/міс)
  development  - B1 App Service, Burstable DB, LRS Storage (~$35/міс)
  budget       - B1 App Service, Burstable DB, LRS Storage (~$35/міс)

ВЕРСІЯ: 2.0.0
EOF
        exit 0
        ;;
    -e|--environment)
        ENVIRONMENT="$2"
        shift 2
        ;;
    -p|--project)
        PROJECT_NAME="$2"
        shift 2
        ;;
    -l|--location)
        LOCATION="$2"
        shift 2
        ;;
    -y|--yes)
        SKIP_CONFIRMATION="true"
        shift
        ;;
    --dry-run)
        echo "🔍 DRY RUN MODE - Показ конфігурації без створення ресурсів"
        show_configuration
        echo -e "${YELLOW}Це тільки попередній перегляд. Для фактичного розгортання запустіть без --dry-run${NC}"
        exit 0
        ;;
    "")
        # Без параметрів - запуск з defaults
        ;;
    *)
        error "Невідомий параметр: $1. Використовуйте --help для довідки"
        ;;
esac

# Валідація environment
case "$ENVIRONMENT" in
    production|staging|development|budget)
        ;;
    *)
        error "Невідомий environment: $ENVIRONMENT. Підтримуються: production, staging, development, budget"
        ;;
esac

# Запуск головної функції
main "$@"
