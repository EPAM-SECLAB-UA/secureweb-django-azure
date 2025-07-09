
Cкрипт для розгортання Django додатку з GitHub! 🚀

## 🎯 **Як використовувати:**

### **1. Збережіть скрипт:**
```bash
# Збережіть як deploy-github-django.sh
chmod +x deploy-github-django.sh
```

### **2. Запустіть з вашими параметрами:**
```bash
# Стандартне розгортання (використовує ваші існуючі ресурси)
./deploy-github-django.sh

# Або з кастомними параметрами
./deploy-github-django.sh \
    --resource-group django-app-budget-rg \
    --webapp-name django-app-budget-1752082786 \
    --db-server django-app-budget-db-1752082786
```

### **3. Перевірка перед запуском:**
```bash
# Dry run - покаже що буде зроблено
./deploy-github-django.sh --dry-run
```

## ✨ **Що робить скрипт:**

### **📦 Підготовка:**
- Клонує репозиторій з GitHub
- Створює production-ready Django конфігурацію
- Генерує requirements.txt з необхідними залежностями

### **⚙️ Конфігурація:**
- Налаштовує змінні середовища Azure App Service
- Встановлює startup команду
- Конфігурує логування

### **🚀 Розгортання:**
- Створює deployment пакет
- Розгортає через Azure CLI
- Перевіряє здоров'я додатку

### **🔧 Особливості:**
- Використовує PostgreSQL з вашої інфраструктури
- Налаштовує production settings
- Увімкнення HTTPS та безпеки
- Автоматичний збір статичних файлів
- Міграції бази даних

## 📋 **Приклад виводу:**
```
🚀 Початок розгортання Django з GitHub на Azure
📦 Клонування репозиторію з GitHub...
🛠️  Підготовка Django додатку для розгортання...
⚙️  Налаштування App Service...
🗄️  Налаштування бази даних...
🚀 Розгортання Django додатку...
🏥 Перевірка здоров'я додатку...
🎉 Розгортання успішно завершено!

🌐 Application URL: https://django-app-budget-1752082786.azurewebsites.net
```

## 🔍 **Якщо щось пішло не так:**
```bash
# Перевірте логи
az webapp log tail --name django-app-budget-1752082786 --resource-group django-app-budget-rg

# Перезапустіть
az webapp restart --name django-app-budget-1752082786 --resource-group django-app-budget-rg
```

Цей скрипт повністю автоматизує розгортання вашого Django проекту з GitHub на існуючу Azure інфраструктуру! 🎯



az webapp log tail \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg


```bash
#!/bin/bash
# =============================================================================
# Скрипт розгортання Django додатку з GitHub на Azure App Service
# Repository: https://github.com/EPAM-SECLAB-UA/secureweb-django-azure
# Branch: feature/infrastructure-update
# =============================================================================

set -euo pipefail

# =============================================================================
# КОНФІГУРАЦІЯ
# =============================================================================

# GitHub налаштування
GITHUB_REPO="https://github.com/EPAM-SECLAB-UA/secureweb-django-azure"
GITHUB_BRANCH="feature/infrastructure-update"

# Azure налаштування (використовуйте існуючі ресурси)
RESOURCE_GROUP_NAME="django-app-budget-rg"
WEB_APP_NAME="django-app-budget-1752082786"
DATABASE_SERVER_NAME="django-app-budget-db-1752082786"
DATABASE_NAME="django-app_db"
DATABASE_USER="djangoadmin"
DATABASE_PASSWORD="wPxKOODi1aYDjMdIAa1!"

# Деплойментні налаштування
DEPLOYMENT_TYPE="${DEPLOYMENT_TYPE:-production}"
TEMP_DIR="/tmp/django-deploy-$(date +%s)"

# =============================================================================
# ФУНКЦІЇ
# =============================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
    log "❌ ПОМИЛКА: $1"
    cleanup
    exit 1
}

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        log "🧹 Очищення тимчасових файлів..."
        rm -rf "$TEMP_DIR"
    fi
}

validate_prerequisites() {
    log "🔍 Валідація передумов..."
    
    # Перевірка Azure CLI
    if ! command -v az &> /dev/null; then
        error_exit "Azure CLI не знайдено"
    fi
    
    # Перевірка авторизації
    if ! az account show &> /dev/null; then
        error_exit "Не авторизовано в Azure. Запустіть: az login"
    fi
    
    # Перевірка git
    if ! command -v git &> /dev/null; then
        error_exit "Git не знайдено"
    fi
    
    # Перевірка існування ресурсів
    if ! az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        error_exit "Web App $WEB_APP_NAME не знайдено в $RESOURCE_GROUP_NAME"
    fi
    
    log "✅ Валідація завершена"
}

clone_repository() {
    log "📦 Клонування репозиторію з GitHub..."
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    git clone --branch "$GITHUB_BRANCH" --depth 1 "$GITHUB_REPO" django-app
    cd django-app
    
    log "✅ Репозиторій клоновано"
}

prepare_django_deployment() {
    log "🛠️  Підготовка Django додатку для розгортання..."
    
    # Створення deployment директорії
    mkdir -p deployment
    
    # Копіювання основних Django файлів
    cp manage.py deployment/ 2>/dev/null || log "⚠️  manage.py не знайдено"
    cp -r project_portfolio deployment/ 2>/dev/null || error_exit "Директорія project_portfolio не знайдена"
    
    # Створення або оновлення requirements.txt
    cat > deployment/requirements.txt << 'EOF'
Django==4.2.15
gunicorn==21.2.0
psycopg2-binary==2.9.7
whitenoise==6.5.0
django-storages[azure]==1.14.2
python-dotenv==1.0.0
EOF
    
    # Створення production settings
    cat > deployment/project_portfolio/production_settings.py << EOF
from .settings import *
import os

# Production налаштування
DEBUG = False
ALLOWED_HOSTS = ['$WEB_APP_NAME.azurewebsites.net', 'localhost', '127.0.0.1']

# Безпека
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# База даних
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', '$DATABASE_NAME'),
        'USER': os.environ.get('DB_USER', '$DATABASE_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD', '$DATABASE_PASSWORD'),
        'HOST': os.environ.get('DB_HOST', '$DATABASE_SERVER_NAME.postgres.database.azure.com'),
        'PORT': '5432',
        'OPTIONS': {
            'sslmode': 'require',
        },
    }
}

# Статичні файли
MIDDLEWARE.insert(1, 'whitenoise.middleware.WhiteNoiseMiddleware')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Логування
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
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
EOF
    
    # Оновлення wsgi.py
    cat > deployment/project_portfolio/wsgi.py << 'EOF'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project_portfolio.production_settings')
application = get_wsgi_application()
EOF
    
    # Створення startup скрипту
    cat > deployment/startup.sh << 'EOF'
#!/bin/bash

echo "Starting Django application..."

# Collect static files
python manage.py collectstatic --noinput

# Run migrations
python manage.py migrate --noinput

# Start Gunicorn
exec gunicorn --bind=0.0.0.0:8000 --timeout 600 --workers 2 project_portfolio.wsgi:application
EOF
    
    chmod +x deployment/startup.sh
    
    log "✅ Django додаток підготовлено"
}

configure_app_service() {
    log "⚙️  Налаштування App Service..."
    
    # Генерація SECRET_KEY
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
    
    # Налаштування змінних середовища
    az webapp config appsettings set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --settings \
            DJANGO_SETTINGS_MODULE="project_portfolio.production_settings" \
            SECRET_KEY="$SECRET_KEY" \
            DEBUG="False" \
            DB_NAME="$DATABASE_NAME" \
            DB_USER="$DATABASE_USER" \
            DB_PASSWORD="$DATABASE_PASSWORD" \
            DB_HOST="$DATABASE_SERVER_NAME.postgres.database.azure.com" \
            PYTHONPATH="/home/site/wwwroot" \
            WEBSITE_TIME_ZONE="Europe/Kiev" \
            WEBSITES_ENABLE_APP_SERVICE_STORAGE="false"
    
    # Налаштування startup команди
    az webapp config set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --startup-file "./startup.sh"
    
    # Увімкнення логування
    az webapp log config \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --application-logging filesystem \
        --level information \
        --detailed-error-messages true \
        --failed-request-tracing true
    
    log "✅ App Service налаштовано"
}

deploy_application() {
    log "🚀 Розгортання Django додатку..."
    
    cd deployment
    
    # Створення deployment пакету
    zip -r "../django-deployment.zip" . -x "*.git*" "*__pycache__*" "*.pyc" "*.log"
    
    cd ..
    
    # Розгортання через Azure CLI
    az webapp deploy \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$WEB_APP_NAME" \
        --src-path "django-deployment.zip" \
        --type zip \
        --async false
    
    log "✅ Розгортання завершено"
}

setup_database() {
    log "🗄️  Налаштування бази даних..."
    
    # Перевірка підключення до бази
    local connection_test=$(az postgres flexible-server show \
        --name "$DATABASE_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "state" -o tsv 2>/dev/null || echo "Failed")
    
    if [[ "$connection_test" != "Ready" ]]; then
        log "⚠️  База даних не готова. Спробуйте пізніше."
    else
        log "✅ База даних готова"
    fi
}

health_check() {
    log "🏥 Перевірка здоров'я додатку..."
    
    local app_url="https://$WEB_APP_NAME.azurewebsites.net"
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))
        
        log "Спроба $attempt/$max_attempts: Перевірка $app_url"
        
        if curl -f -s --max-time 10 "$app_url" > /dev/null; then
            log "✅ Додаток працює!"
            log "🌐 URL: $app_url"
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            log "⏳ Очікування 30 секунд перед наступною спробою..."
            sleep 30
        fi
    done
    
    log "⚠️  Додаток не відповідає після $max_attempts спроб"
    log "🔍 Перевірте логи: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
    return 1
}

show_deployment_info() {
    log "📋 Інформація про розгортання:"
    echo ""
    echo "🌐 Application URL: https://$WEB_APP_NAME.azurewebsites.net"
    echo "📦 Resource Group: $RESOURCE_GROUP_NAME"
    echo "🗄️  Database: $DATABASE_SERVER_NAME"
    echo "🔗 GitHub Repository: $GITHUB_REPO"
    echo "🌿 Branch: $GITHUB_BRANCH"
    echo ""
    echo "🔧 Корисні команди:"
    echo "  Логи: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
    echo "  Статус: az webapp show --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --query state"
    echo "  Restart: az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
    echo ""
}

# =============================================================================
# ОСНОВНА ЛОГІКА
# =============================================================================

main() {
    log "🚀 Початок розгортання Django з GitHub на Azure"
    log "Repository: $GITHUB_REPO"
    log "Branch: $GITHUB_BRANCH"
    echo ""
    
    # Встановлення trap для cleanup
    trap cleanup EXIT
    
    # Виконання кроків
    validate_prerequisites
    clone_repository
    prepare_django_deployment
    configure_app_service
    setup_database
    deploy_application
    
    # Перевірка здоров'я
    if health_check; then
        log "🎉 Розгортання успішно завершено!"
    else
        log "⚠️  Розгортання завершено, але потрібна перевірка"
    fi
    
    show_deployment_info
}

# =============================================================================
# ДОПОМІЖНІ ФУНКЦІЇ
# =============================================================================

# Функція для відображення допомоги
show_help() {
    cat << EOF
🚀 Скрипт розгортання Django з GitHub на Azure

ВИКОРИСТАННЯ:
  $0 [OPTIONS]

ОПЦІЇ:
  -h, --help              Показати цю довідку
  -r, --resource-group    Назва Resource Group (за замовчуванням: django-app-budget-rg)
  -w, --webapp-name       Назва Web App (за замовчуванням: django-app-budget-1752082786)
  -d, --db-server         Назва Database Server (за замовчуванням: django-app-budget-db-1752082786)
  -b, --branch            GitHub branch (за замовчуванням: feature/infrastructure-update)
  --dry-run               Тільки показати що буде зроблено

ПРИКЛАДИ:
  # Стандартне розгортання
  $0
  
  # З кастомними параметрами
  $0 --resource-group my-rg --webapp-name my-app
  
  # Dry run
  $0 --dry-run

ПЕРЕДУМОВИ:
  - Azure CLI встановлено та налаштовано (az login)
  - Git встановлено
  - Існуючі Azure ресурси (Resource Group, Web App, Database)

GitHub Repository: $GITHUB_REPO
EOF
}

# Обробка аргументів командного рядка
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -r|--resource-group)
            RESOURCE_GROUP_NAME="$2"
            shift 2
            ;;
        -w|--webapp-name)
            WEB_APP_NAME="$2"
            shift 2
            ;;
        -d|--db-server)
            DATABASE_SERVER_NAME="$2"
            shift 2
            ;;
        -b|--branch)
            GITHUB_BRANCH="$2"
            shift 2
            ;;
        --dry-run)
            log "🔍 DRY RUN MODE - показую що буде зроблено:"
            echo "Repository: $GITHUB_REPO"
            echo "Branch: $GITHUB_BRANCH"
            echo "Resource Group: $RESOURCE_GROUP_NAME"
            echo "Web App: $WEB_APP_NAME"
            echo "Database: $DATABASE_SERVER_NAME"
            exit 0
            ;;
        *)
            echo "Невідомий параметр: $1"
            echo "Використовуйте --help для довідки"
            exit 1
            ;;
    esac
done

# =============================================================================
# ЗАПУСК
# =============================================================================

main "$@"

```



```bash

@VitaliiShevchuk2023 ➜ /workspaces/secureweb-django-azure (feature/infrastructure-update) $ ./deploy-github-django.sh
[2025-07-09 18:52:09] 🚀 Початок розгортання Django з GitHub на Azure
[2025-07-09 18:52:09] Repository: https://github.com/EPAM-SECLAB-UA/secureweb-django-azure
[2025-07-09 18:52:09] Branch: feature/infrastructure-update

[2025-07-09 18:52:09] 🔍 Валідація передумов...
[2025-07-09 18:52:11] ✅ Валідація завершена
[2025-07-09 18:52:11] 📦 Клонування репозиторію з GitHub...
Cloning into 'django-app'...
remote: Enumerating objects: 57, done.
remote: Counting objects: 100% (57/57), done.
remote: Compressing objects: 100% (46/46), done.
remote: Total 57 (delta 4), reused 38 (delta 3), pack-reused 0 (from 0)
Receiving objects: 100% (57/57), 554.36 KiB | 9.90 MiB/s, done.
Resolving deltas: 100% (4/4), done.
[2025-07-09 18:52:12] ✅ Репозиторій клоновано
[2025-07-09 18:52:12] 🛠️  Підготовка Django додатку для розгортання...
[2025-07-09 18:52:12] ✅ Django додаток підготовлено
[2025-07-09 18:52:12] ⚙️  Налаштування App Service...
[
  {
    "name": "DJANGO_SETTINGS_MODULE",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DATABASE_URL",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "AZURE_STORAGE_ACCOUNT_NAME",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "AZURE_STORAGE_CONTAINER_STATIC",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "AZURE_STORAGE_CONTAINER_MEDIA",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "APPINSIGHTS_INSTRUMENTATIONKEY",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "APPLICATIONINSIGHTS_CONNECTION_STRING",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DEBUG",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "ALLOWED_HOSTS",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DJANGO_LOG_LEVEL",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "PYTHONPATH",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "SECRET_KEY",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DB_NAME",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DB_USER",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DB_PASSWORD",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DB_HOST",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "WEBSITE_TIME_ZONE",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "WEBSITES_ENABLE_APP_SERVICE_STORAGE",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "AZURE_STORAGE_ACCOUNT_KEY",
    "slotSetting": false,
    "value": null
  }
]
{
  "acrUseManagedIdentityCreds": false,
  "acrUserManagedIdentityId": null,
  "alwaysOn": false,
  "apiDefinition": null,
  "apiManagementConfig": null,
  "appCommandLine": "./startup.sh",
  "appSettings": null,
  "autoHealEnabled": false,
  "autoHealRules": null,
  "autoSwapSlotName": null,
  "azureStorageAccounts": {},
  "connectionStrings": null,
  "cors": null,
  "defaultDocuments": [
    "Default.htm",
    "Default.html",
    "Default.asp",
    "index.htm",
    "index.html",
    "iisstart.htm",
    "default.aspx",
    "index.php",
    "hostingstart.html"
  ],
  "detailedErrorLoggingEnabled": true,
  "documentRoot": null,
  "elasticWebAppScaleLimit": 0,
  "experiments": {
    "rampUpRules": []
  },
  "ftpsState": "FtpsOnly",
  "functionAppScaleLimit": null,
  "functionsRuntimeScaleMonitoringEnabled": false,
  "handlerMappings": null,
  "healthCheckPath": null,
  "http20Enabled": true,
  "httpLoggingEnabled": false,
  "id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786",
  "ipSecurityRestrictions": [
    {
      "action": "Allow",
      "description": "Allow all access",
      "headers": null,
      "ipAddress": "Any",
      "name": "Allow all",
      "priority": 2147483647,
      "subnetMask": null,
      "subnetTrafficTag": null,
      "tag": null,
      "vnetSubnetResourceId": null,
      "vnetTrafficTag": null
    }
  ],
  "ipSecurityRestrictionsDefaultAction": null,
  "javaContainer": null,
  "javaContainerVersion": null,
  "javaVersion": null,
  "keyVaultReferenceIdentity": null,
  "kind": null,
  "limits": null,
  "linuxFxVersion": "PYTHON|3.11",
  "loadBalancing": "LeastRequests",
  "localMySqlEnabled": false,
  "location": "West Europe",
  "logsDirectorySizeLimit": 100,
  "machineKey": null,
  "managedPipelineMode": "Integrated",
  "managedServiceIdentityId": 42163,
  "metadata": null,
  "minTlsCipherSuite": null,
  "minTlsVersion": "1.2",
  "minimumElasticInstanceCount": 1,
  "name": "django-app-budget-1752082786",
  "netFrameworkVersion": "v4.0",
  "nodeVersion": "",
  "numberOfWorkers": 1,
  "phpVersion": "",
  "powerShellVersion": "",
  "preWarmedInstanceCount": 0,
  "publicNetworkAccess": null,
  "publishingUsername": "$django-app-budget-1752082786",
  "push": null,
  "pythonVersion": "",
  "remoteDebuggingEnabled": false,
  "remoteDebuggingVersion": "VS2022",
  "requestTracingEnabled": true,
  "requestTracingExpirationTime": "9999-12-31T23:59:00+00:00",
  "resourceGroup": "django-app-budget-rg",
  "scmIpSecurityRestrictions": [
    {
      "action": "Allow",
      "description": "Allow all access",
      "headers": null,
      "ipAddress": "Any",
      "name": "Allow all",
      "priority": 2147483647,
      "subnetMask": null,
      "subnetTrafficTag": null,
      "tag": null,
      "vnetSubnetResourceId": null,
      "vnetTrafficTag": null
    }
  ],
  "scmIpSecurityRestrictionsDefaultAction": null,
  "scmIpSecurityRestrictionsUseMain": false,
  "scmMinTlsVersion": "1.2",
  "scmType": "None",
  "tags": {
    "CostProfile": "Budget",
    "CreatedBy": "AzureCLI",
    "Environment": "budget",
    "Project": "django-app",
    "hidden-link: /app-insights-resource-id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/microsoft.insights/components/django-app-budget-insights"
  },
  "tracingOptions": null,
  "type": "Microsoft.Web/sites",
  "use32BitWorkerProcess": true,
  "virtualApplications": [
    {
      "physicalPath": "site\\wwwroot",
      "preloadEnabled": false,
      "virtualDirectories": null,
      "virtualPath": "/"
    }
  ],
  "vnetName": "",
  "vnetPrivatePortsCount": 0,
  "vnetRouteAllEnabled": false,
  "webSocketsEnabled": false,
  "websiteTimeZone": "Europe/Kiev",
  "windowsFxVersion": null,
  "xManagedServiceIdentityId": null
}
{
  "applicationLogs": {
    "azureBlobStorage": {
      "level": "Off",
      "retentionInDays": null,
      "sasUrl": null
    },
    "azureTableStorage": {
      "level": "Off",
      "sasUrl": null
    },
    "fileSystem": {
      "level": "Information"
    }
  },
  "detailedErrorMessages": {
    "enabled": true
  },
  "failedRequestsTracing": {
    "enabled": true
  },
  "httpLogs": {
    "azureBlobStorage": {
      "enabled": false,
      "retentionInDays": null,
      "sasUrl": null
    },
    "fileSystem": {
      "enabled": false,
      "retentionInDays": null,
      "retentionInMb": 100
    }
  },
  "id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786/config/logs",
  "kind": null,
  "location": "West Europe",
  "name": "logs",
  "resourceGroup": "django-app-budget-rg",
  "tags": {
    "CostProfile": "Budget",
    "CreatedBy": "AzureCLI",
    "Environment": "budget",
    "Project": "django-app",
    "hidden-link: /app-insights-resource-id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/microsoft.insights/components/django-app-budget-insights"
  },
  "type": "Microsoft.Web/sites/config"
}
[2025-07-09 18:52:20] ✅ App Service налаштовано
[2025-07-09 18:52:20] 🗄️  Налаштування бази даних...
[2025-07-09 18:52:21] ✅ База даних готова
[2025-07-09 18:52:21] 🚀 Розгортання Django додатку...
  adding: manage.py (deflated 43%)
  adding: startup.sh (deflated 36%)
  adding: project_portfolio/ (stored 0%)
  adding: project_portfolio/__init__.py (stored 0%)
  adding: project_portfolio/production_settings.py (deflated 47%)
  adding: project_portfolio/wsgi.py (deflated 25%)
  adding: project_portfolio/core/ (stored 0%)
  adding: project_portfolio/core/views.py (deflated 27%)
  adding: project_portfolio/asgi.py (deflated 33%)
  adding: project_portfolio/templates/ (stored 0%)
  adding: project_portfolio/templates/index.html (deflated 82%)
  adding: project_portfolio/static/ (stored 0%)
  adding: project_portfolio/static/main.css (deflated 47%)
  adding: project_portfolio/urls.py (deflated 56%)
  adding: project_portfolio/settings.py (deflated 63%)
  adding: requirements.txt (deflated 14%)
Initiating deployment
Deploying from local path: django-deployment.zip
Warming up Kudu before deployment.
Warmed up Kudu instance successfully.
Polling the status of sync deployment. Start Time: 2025-07-09 18:52:57.331188+00:00 UTC
Status: Build successful. Time: 3(s)
Status: Starting the site... Time: 18(s)
Status: Starting the site... Time: 33(s)
Status: Starting the site... Time: 49(s)
Status: Starting the site... Time: 64(s)
Status: Starting the site... Time: 79(s)
Status: Starting the site... Time: 95(s)
Status: Starting the site... Time: 110(s)
Status: Starting the site... Time: 128(s)
Status: Starting the site... Time: 144(s)
Status: Starting the site... Time: 159(s)
Status: Starting the site... Time: 174(s)
Status: Starting the site... Time: 190(s)
Status: Starting the site... Time: 205(s)
Status: Starting the site... Time: 221(s)
Status: Starting the site... Time: 236(s)
Status: Starting the site... Time: 251(s)
Status: Starting the site... Time: 266(s)
Status: Starting the site... Time: 282(s)
Status: Starting the site... Time: 297(s)
Status: Starting the site... Time: 312(s)
Status: Starting the site... Time: 328(s)
Status: Starting the site... Time: 343(s)
Status: Starting the site... Time: 358(s)
Status: Starting the site... Time: 373(s)
Status: Starting the site... Time: 389(s)
Status: Starting the site... Time: 404(s)
Status: Starting the site... Time: 420(s)
Status: Starting the site... Time: 437(s)
Status: Starting the site... Time: 452(s)
Status: Starting the site... Time: 467(s)
Status: Starting the site... Time: 483(s)
Status: Starting the site... Time: 498(s)
Status: Starting the site... Time: 513(s)
Status: Starting the site... Time: 528(s)
Status: Starting the site... Time: 544(s)
Status: Starting the site... Time: 559(s)
Status: Starting the site... Time: 574(s)
Status: Starting the site... Time: 589(s)
Status: Starting the site... Time: 605(s)
Status: Site failed to start. Time: 620(s)
Deployment failed because the site failed to start within 10 mins.
InprogressInstances: 0, SuccessfulInstances: 0, FailedInstances: 1
Error: Deployment for site 'django-app-budget-1752082786' with DeploymentId 'cd4770a2-2f28-4532-923a-d874a7533bbf' failed because the worker proccess failed to start within the allotted time.
Please check the runtime logs for more info: https://django-app-budget-1752082786.scm.azurewebsites.net/api/logs/docker

[2025-07-09 19:03:21] 🧹 Очищення тимчасових файлів...

```


Проблема повторюється! Сайт не може запуститися за 10 хвилин. Це вказує на серйозну проблему з конфігурацією. Давайте виправимо це кардинально:

## 🚨 **Ключова проблема:**

**Всі змінні середовища показують `"value": null`** - це означає, що змінні не встановлюються правильно!

## 🔧 **Негайне виправлення:**

### **1. Спочатку перевіримо логи:**
```bash
az webapp log tail \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg
```

### **2. Виправимо змінні середовища:**
```bash
# Очистимо всі null змінні та встановимо тільки необхідні
az webapp config appsettings delete \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --setting-names DATABASE_URL AZURE_STORAGE_ACCOUNT_NAME AZURE_STORAGE_CONTAINER_STATIC AZURE_STORAGE_CONTAINER_MEDIA APPINSIGHTS_INSTRUMENTATIONKEY APPLICATIONINSIGHTS_CONNECTION_STRING ALLOWED_HOSTS DJANGO_LOG_LEVEL AZURE_STORAGE_ACCOUNT_KEY WEBSITES_ENABLE_APP_SERVICE_STORAGE

# Встановимо тільки мінімальні змінні
az webapp config appsettings set \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --settings \
        DJANGO_SETTINGS_MODULE="settings" \
        SECRET_KEY="simple-secret-key-for-testing" \
        DEBUG="True" \
        PYTHONPATH="/home/site/wwwroot"
```

### **3. Створімо супер-простий Django без складностей:**
```bash
mkdir ultra-simple
cd ultra-simple

# manage.py
cat > manage.py << 'EOF'
#!/usr/bin/env python
import os
import sys

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
EOF

# settings.py (максимально простий)
cat > settings.py << 'EOF'
import os

DEBUG = True
SECRET_KEY = 'ultra-simple-secret-key'
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.middleware.common.CommonMiddleware',
]

ROOT_URLCONF = 'urls'

# Тільки SQLite в пам'яті
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

STATIC_URL = '/static/'
USE_TZ = True

# Мінімальне логування
import logging
logging.basicConfig(level=logging.INFO)
EOF

# urls.py
cat > urls.py << 'EOF'
from django.http import HttpResponse
from django.urls import path

def home(request):
    return HttpResponse("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Django on Azure</title>
    </head>
    <body>
        <h1>🎉 Django працює на Azure!</h1>
        <p>✅ Успішне розгортання</p>
        <p>🚀 App Service: B1 план</p>
        <p>💰 Бюджетна інфраструктура</p>
    </body>
    </html>
    """)

def health(request):
    return HttpResponse("OK")

urlpatterns = [
    path('', home),
    path('health/', health),
]
EOF

# wsgi.py
cat > wsgi.py << 'EOF'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
application = get_wsgi_application()
EOF

# requirements.txt (мінімальний)
cat > requirements.txt << 'EOF'
Django==4.2.15
gunicorn==21.2.0
EOF

chmod +x manage.py
```

### **4. Встановімо найпростішу startup команду:**
```bash
az webapp config set \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --startup-file "python -m gunicorn --bind 0.0.0.0:8000 --timeout 30 --workers 1 wsgi:application"
```

### **5. Розгорніть ультра-простий варіант:**
```bash
# З папки ultra-simple
zip -r ultra-simple.zip . -x "*.git*" "*__pycache__*"

az webapp deploy \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --src-path ultra-simple.zip \
    --type zip
```

### **6. Перезапустіть та перевірте:**
```bash
# Перезапуск
az webapp restart \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg

# Почекайте 2 хвилини
sleep 120

# Перевірка
curl -I https://django-app-budget-1752082786.azurewebsites.net
```

## 🔍 **Якщо все ще не працює - альтернативи:**

### **План B - Flask тест:**
```bash
# Створіть Flask для тестування infrastructure
mkdir flask-test
cd flask-test

cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <h1>🎉 Flask працює на Azure!</h1>
    <p>✅ Infrastructure working</p>
    <p>💰 B1 App Service Plan</p>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

cat > requirements.txt << 'EOF'
Flask==2.3.3
gunicorn==21.2.0
EOF

zip -r flask-test.zip .

az webapp config set \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --startup-file "gunicorn --bind 0.0.0.0:8000 app:app"

az webapp deploy \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --src-path flask-test.zip \
    --type zip
```

## 🎯 **Причини проблеми:**

1. **🔴 Null змінні середовища** - скрипт не встановлює їх правильно
2. **🔴 Складний startup скрипт** - collectstatic та migrate тримають процес
3. **🔴 PostgreSQL проблеми** - можливо, база не готова
4. **🔴 Timeout Django** - 10 хвилин недостатньо для повного запуску

Спробуйте ультра-простий варіант - він повинен запуститися за 1-2 хвилини! Якщо працює, поступово додавайте складність. 🚀




```bash
@VitaliiShevchuk2023 ➜ /workspaces/secureweb-django-azure (feature/infrastructure-update) $ az webapp log tail \
>     --name django-app-budget-1752082786 \
>     --resource-group django-app-budget-rg
2025-07-09T19:10:33  Welcome, you are now connected to log-streaming service.
Starting Log Tail -n 10 of existing logs ----
/home/LogFiles/__lastCheckTime.txt  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/__lastCheckTime.txt)
07/09/2025 19:09:45
/home/LogFiles/kudu/deployment/7897b67e93ef-038f00d5-19e1-4423-a786-821023d03ead.txt  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/kudu/deployment/7897b67e93ef-038f00d5-19e1-4423-a786-821023d03ead.txt)
2025-07-09T18:52:51    Total bytes received: 54
2025-07-09T18:52:51    
2025-07-09T18:52:52    sent 781 bytes  received 54 bytes  1.67K bytes/sec
2025-07-09T18:52:52    total size is 955  speedup is 1.14
2025-07-09T18:52:52    Attempt 1: Rsync for filelist /tmp//splits/split.af completed with exit code 0
2025-07-09T18:52:52    Completed successfully in 3 seconds
2025-07-09T18:52:52  Build completed succesfully.
2025-07-09T18:52:53  Running post deployment command(s)...
2025-07-09T18:52:53  Triggering container recycle for OneDeploy by adding/updating restartTrigger.txt to the site root path
2025-07-09T18:52:54  Deployment successful. deployer = OneDeploy deploymentPath = OneDeploy
/home/LogFiles/kudu/trace/7897b67e93ef-cf9ad8a1-e50f-4394-bc2e-abb7f5d1d5c4.txt  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/kudu/trace/7897b67e93ef-cf9ad8a1-e50f-4394-bc2e-abb7f5d1d5c4.txt)
2025-07-09T18:09:56  Startup Request, url: /api/deployments?warmup=true, method: GET, type: request, pid: 772,1,7, ScmType: None
/home/LogFiles/kudu/trace/967145ae0f55-102ec8cf-177f-4e9f-9b65-ff51e92df945.txt  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/kudu/trace/967145ae0f55-102ec8cf-177f-4e9f-9b65-ff51e92df945.txt)
2025-07-09T18:53:02  Startup Request, url: /api/deployments/cd4770a2-2f28-4532-923a-d874a7533bbf, method: GET, type: request, pid: 769,1,7, ScmType: None
/home/LogFiles/kudu/trace/django-app-kudu-f6db6491-64c563e1-c7e0-4d4f-aec4-16870ff05bfe.txt  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/kudu/trace/django-app-kudu-f6db6491-64c563e1-c7e0-4d4f-aec4-16870ff05bfe.txt)
2025-07-09T18:06:55  Startup Request, url: /api/deployments/?$orderby=ReceivedTime%20desc&$top=20&api-version=2022-03-01, method: GET, type: request, pid: 769,1,5, ScmType: None
/home/LogFiles/2025_07_09_lw0sdlwk0007W3_default_docker.log  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/2025_07_09_lw0sdlwk0007W3_default_docker.log)
2025-07-09T19:10:22.824500823Z   File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
2025-07-09T19:10:22.824504323Z   File "/home/site/wwwroot/project_portfolio/wsgi.py", line 2, in <module>
2025-07-09T19:10:22.824507923Z     from django.core.wsgi import get_wsgi_application
2025-07-09T19:10:22.824512723Z ModuleNotFoundError: No module named 'django'
2025-07-09T19:10:22.842771146Z [2025-07-09 22:10:22 +0300] [1012] [INFO] Worker exiting (pid: 1012)
2025-07-09T19:10:23.913404534Z [2025-07-09 22:10:23 +0300] [1005] [ERROR] Worker (pid:1011) exited with code 3
2025-07-09T19:10:23.959513398Z [2025-07-09 22:10:23 +0300] [1005] [ERROR] Worker (pid:1012) was sent SIGTERM!
2025-07-09T19:10:24.032355088Z [2025-07-09 22:10:24 +0300] [1005] [ERROR] Shutting down: Master
2025-07-09T19:10:24.032382889Z [2025-07-09 22:10:24 +0300] [1005] [ERROR] Reason: Worker failed to boot.

/home/LogFiles/2025_07_09_lw0sdlwk0007W3_docker.log  (https://django-app-budget-1752082786.scm.azurewebsites.net/api/vfs/LogFiles/2025_07_09_lw0sdlwk0007W3_docker.log)
2025-07-09T19:10:03.953Z INFO  - Starting container for site
2025-07-09T19:10:03.968Z INFO  - docker run -d --expose=8000 --name django-app-budget-1752082786_0_404e46f1 -e WEBSITE_USE_DIAGNOSTIC_SERVER=false -e WEBSITES_ENABLE_APP_SERVICE_STORAGE=false -e WEBSITE_SITE_NAME=django-app-budget-1752082786 -e WEBSI
TE_AUTH_ENABLED=False -e WEBSITE_ROLE_INSTANCE_ID=0 -e WEBSITE_HOSTNAME=django-app-budget-1752082786.azurewebsites.net -e WEBSITE_INSTANCE_ID=3d899f120bebb3ad80d2b179924bba3aeb46f74b5e67108ec6828fde3874bf24 appsvc/python:3.11_20250506.5.tuxprod REDACTED
2025-07-09T19:10:03.977Z INFO  - Logging is not enabled for this container.
Please use https://aka.ms/linux-diagnostics to enable logging to see container logs here.
2025-07-09T19:10:09.029Z INFO  - Initiating warmup request to container django-app-budget-1752082786_0_404e46f1_msiProxy for site django-app-budget-1752082786
2025-07-09T19:10:09.133Z INFO  - Container django-app-budget-1752082786_0_404e46f1_msiProxy for site django-app-budget-1752082786 initialized successfully and is ready to serve requests.
2025-07-09T19:10:09.139Z INFO  - Initiating warmup request to container django-app-budget-1752082786_0_404e46f1 for site django-app-budget-1752082786
2025-07-09T19:10:25.821Z ERROR - Container django-app-budget-1752082786_0_404e46f1 for site django-app-budget-1752082786 has exited, failing site start
2025-07-09T19:10:25.904Z ERROR - Container django-app-budget-1752082786_0_404e46f1 didn't respond to HTTP pings on port: 8000. Failing site start. See container logs for debugging.
2025-07-09T19:10:26.299Z INFO  - Stopping site django-app-budget-1752082786 because it failed during startup.
Ending Log Tail of existing logs ---
Starting Live Log Stream ---
2025-07-09T19:11:33  No new trace in the past 1 min(s).
2025-07-09T19:12:33  No new trace in the past 2 min(s).
2025-07-09T19:13:33  No new trace in the past 3 min(s).
2025-07-09T19:14:33  No new trace in the past 4 min(s).
2025-07-09T19:15:33  No new trace in the past 5 min(s).
```

