


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


Ось повний скрипт для розгортання Django додатку з GitHub! 🚀

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
