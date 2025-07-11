
Ось кілька варіантів назв для файлу з документацією:

## 🎯 **Рекомендовані варіанти:**

### **1. Англійською (стандартний підхід):**
```
DJANGO_CODESPACE_AZURE_GUIDE.md
django-codespace-azure-deployment.md
django-postgresql-codespace-azure.md
codespace-to-azure-deployment-guide.md
```

### **2. Україномовні варіанти:**
```
DJANGO_CODESPACE_AZURE_ГАЙД.md
django-postgresql-розробка-azure.md
повний-гайд-django-azure.md
```

### **3. Змішані варіанти:**
```
DJANGO_CODESPACE_AZURE_GUIDE_UA.md
django-codespace-azure-guide-ukrainian.md
```

## 🏆 **Найкращий варіант:**

```
DJANGO_CODESPACE_AZURE_GUIDE.md
```

**Чому саме цей:**
- ✅ Зрозуміло з назви про що документ
- ✅ Англійською - стандарт для технічної документації
- ✅ ЗАГЛАВНИМИ літерами - виділяється в файловій структурі
- ✅ Коротко але інформативно
- ✅ Легко знайти в проекті

## 📁 **Розміщення в проекті:**

```
django-project/
├── docs/
│   ├── DJANGO_CODESPACE_AZURE_GUIDE.md
│   ├── DEPLOYMENT.md
│   └── DEVELOPMENT.md
├── README.md
└── ...
```

## 🔄 **Альтернативна структура документації:**

Якщо хочете розбити на кілька файлів:

```
docs/
├── development/
│   ├── CODESPACE_SETUP.md
│   ├── LOCAL_DEVELOPMENT.md
│   └── TESTING.md
├── deployment/
│   ├── AZURE_DEPLOYMENT.md
│   ├── CI_CD_SETUP.md
│   └── PRODUCTION_CONFIG.md
└── FULL_GUIDE.md (основний файл з посиланнями)
```

## 📝 **Додаткові рекомендації:**

1. **Додайте до README.md посилання:**
```markdown
## 📚 Документація
- [Повний гайд розгортання](docs/DJANGO_CODESPACE_AZURE_GUIDE.md)
```

2. **Використовуйте емодзі для розділів:**
```markdown
# 🚀 Django + PostgreSQL: Codespace → Azure
```

3. **Створіть index файл для документації:**
```markdown
# 📖 Документація проекту

## Гайди
- [🚀 Повний гайд розгортання](DJANGO_CODESPACE_AZURE_GUIDE.md)
- [⚙️ Налаштування розробки](DEVELOPMENT_SETUP.md)
- [☁️ Azure конфігурація](AZURE_CONFIG.md)
```

**Мій фінальний вибір:** `DJANGO_CODESPACE_AZURE_GUIDE.md` 🎯



# 🚀 Повний гайд: Django + PostgreSQL в GitHub Codespace → Azure

## 📋 Зміст
1. [Структура проекту](#структура-проекту)
2. [Налаштування GitHub Codespace](#налаштування-github-codespace)
3. [Django конфігурація](#django-конфігурація)
4. [Локальна розробка](#локальна-розробка)
5. [Підготовка до Azure](#підготовка-до-azure)
6. [Деплой в Azure](#деплой-в-azure)
7. [CI/CD Pipeline](#cicd-pipeline)

---

## 📁 Структура проекту

```
django-azure-project/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   └── Dockerfile
├── .github/
│   └── workflows/
│       └── azure-deploy.yml
├── project_name/
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   ├── production.py
│   │   └── testing.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   └── core/
├── static/
├── templates/
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   ├── production.txt
│   └── testing.txt
├── scripts/
│   ├── azure-deploy.sh
│   └── setup-local.sh
├── .env.example
├── .gitignore
├── manage.py
├── requirements.txt → symlink to requirements/production.txt
└── README.md
```

---

## ⚙️ Налаштування GitHub Codespace

### 1. `.devcontainer/devcontainer.json`

```json
{
  "name": "Django PostgreSQL Development",
  "dockerComposeFile": "docker-compose.yml",
  "service": "web",
  "workspaceFolder": "/workspace",
  
  "customizations": {
    "vscode": {
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.formatting.provider": "black",
        "python.linting.flake8Enabled": true,
        "python.testing.pytestEnabled": true,
        "files.exclude": {
          "**/__pycache__": true,
          "**/*.pyc": true
        }
      },
      "extensions": [
        "ms-python.python",
        "ms-python.flake8",
        "ms-python.black-formatter",
        "ms-toolsai.jupyter",
        "mtxr.sqltools",
        "mtxr.sqltools-driver-pg",
        "ms-vscode.vscode-json",
        "bradlc.vscode-tailwindcss",
        "formulahendry.auto-rename-tag"
      ]
    }
  },
  
  "forwardPorts": [8000, 5432],
  "portsAttributes": {
    "8000": {
      "label": "Django Development Server",
      "onAutoForward": "notify"
    },
    "5432": {
      "label": "PostgreSQL Database",
      "onAutoForward": "silent"
    }
  },
  
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "postAttachCommand": "python manage.py runserver 0.0.0.0:8000",
  
  "remoteUser": "vscode",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/git:1": {}
  }
}
```

### 2. `.devcontainer/docker-compose.yml`

```yaml
version: '3.8'

services:
  web:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - ../..:/workspaces:cached
      - /var/run/docker.sock:/var/run/docker.sock
    command: sleep infinity
    environment:
      - DJANGO_SETTINGS_MODULE=project_name.settings.development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/django_dev
      - DEBUG=True
    depends_on:
      - db
      - redis
    ports:
      - "8000:8000"

  db:
    image: postgres:15-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: django_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 3. `.devcontainer/Dockerfile`

```dockerfile
FROM python:3.11-slim

# Встановлення системних залежностей
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Створення користувача vscode
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Встановлення Python залежностей
COPY requirements/development.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/development.txt

USER $USERNAME
```

### 4. `.devcontainer/post-create.sh`

```bash
#!/bin/bash

# Встановлення залежностей
pip install -r requirements/development.txt

# Очікування готовності БД
echo "Очікування готовності PostgreSQL..."
while ! pg_isready -h db -p 5432 -U postgres; do
  sleep 1
done

# Застосування міграцій
python manage.py migrate

# Створення суперюзера (якщо потрібно)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Збір статичних файлів
python manage.py collectstatic --noinput

echo "🚀 Розробницьке середовище готове!"
```

---

## 🔧 Django конфігурація

### 1. `project_name/settings/base.py`

```python
import os
from pathlib import Path
from decouple import config
import dj_database_url

BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Security
SECRET_KEY = config('SECRET_KEY', default='django-insecure-change-me')
DEBUG = config('DEBUG', default=False, cast=bool)

# Applications
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'corsheaders',
]

LOCAL_APPS = [
    'apps.core',
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

ROOT_URLCONF = 'project_name.urls'

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

WSGI_APPLICATION = 'project_name.wsgi.application'

# Database
DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL', default='sqlite:///db.sqlite3')
    )
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Internationalization
LANGUAGE_CODE = 'uk-ua'
TIME_ZONE = 'Europe/Kiev'
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
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': BASE_DIR / 'logs' / 'django.log',
            'formatter': 'verbose',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
}
```

### 2. `project_name/settings/development.py`

```python
from .base import *

DEBUG = True

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '0.0.0.0',
    '.githubpreview.dev',
    '.preview.app.github.dev',
    '*.codespaces.githubusercontent.com',
]

# Development tools
INSTALLED_APPS += [
    'debug_toolbar',
    'django_extensions',
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
]

# Debug toolbar configuration
INTERNAL_IPS = [
    '127.0.0.1',
    '0.0.0.0',
]

# Email backend for development
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# CORS settings for development
CORS_ALLOW_ALL_ORIGINS = True

# Cache
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://redis:6379/1',
    }
}
```

### 3. `project_name/settings/production.py`

```python
from .base import *
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration

DEBUG = False

ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='').split(',')

# Security settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_SECONDS = 31536000
SECURE_REDIRECT_EXEMPT = []
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
USE_TZ = True

# Azure Storage
if config('AZURE_STORAGE_ACCOUNT_NAME', default=None):
    DEFAULT_FILE_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    AZURE_STORAGE_ACCOUNT_NAME = config('AZURE_STORAGE_ACCOUNT_NAME')
    AZURE_STORAGE_ACCOUNT_KEY = config('AZURE_STORAGE_ACCOUNT_KEY')
    AZURE_STORAGE_CONTAINER_NAME = config('AZURE_STORAGE_CONTAINER_NAME', default='media')

# Static files with WhiteNoise
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Database connection pooling
DATABASES['default']['CONN_MAX_AGE'] = 600

# Cache with Redis
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': config('REDIS_URL', default='redis://localhost:6379/1'),
    }
}

# Email
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = config('EMAIL_HOST', default='')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = True
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')

# Sentry error tracking (optional)
if config('SENTRY_DSN', default=None):
    sentry_sdk.init(
        dsn=config('SENTRY_DSN'),
        integrations=[DjangoIntegration()],
        traces_sample_rate=0.1,
        send_default_pii=True
    )
```

---

## 🏃‍♂️ Локальна розробка

### 1. `.env.example`

```env
# Django
SECRET_KEY=your-secret-key-here
DEBUG=True
DJANGO_SETTINGS_MODULE=project_name.settings.development

# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/django_dev

# Cache
REDIS_URL=redis://redis:6379/1

# Azure (for production)
AZURE_STORAGE_ACCOUNT_NAME=
AZURE_STORAGE_ACCOUNT_KEY=
AZURE_STORAGE_CONTAINER_NAME=

# Email
EMAIL_HOST=
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=

# Monitoring
SENTRY_DSN=

# Security
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com
```

### 2. `requirements/base.txt`

```txt
Django>=4.2,<5.0
psycopg2-binary>=2.9.5
python-decouple>=3.6
dj-database-url>=2.0.0
whitenoise>=6.2.0
django-cors-headers>=3.13.0
redis>=4.5.0
django-redis>=5.2.0
Pillow>=9.4.0
```

### 3. `requirements/development.txt`

```txt
-r base.txt

django-debug-toolbar>=3.2.4
django-extensions>=3.2.1
ipython>=8.8.0
pytest-django>=4.5.2
pytest-cov>=4.0.0
black>=22.12.0
flake8>=6.0.0
isort>=5.11.4
```

### 4. `requirements/production.txt`

```txt
-r base.txt

gunicorn>=20.1.0
django-storages[azure]>=1.13.2
sentry-sdk[django]>=1.14.0
```

---

## ☁️ Підготовка до Azure

### 1. `scripts/azure-deploy.sh`

```bash
#!/bin/bash

set -e

# Змінні
RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
APP_NAME="django-portfolio-app"
DB_NAME="django-db"
STORAGE_ACCOUNT="djangostorage$(date +%s)"

echo "🚀 Початок розгортання Django додатка в Azure..."

# Перевірка Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI не встановлений"
    exit 1
fi

# Створення Resource Group
echo "📦 Створення Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Створення App Service Plan
echo "🏗️ Створення App Service Plan..."
az appservice plan create \
    --name "${APP_NAME}-plan" \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku B1 \
    --is-linux

# Створення PostgreSQL сервера
echo "🗄️ Створення PostgreSQL сервера..."
az postgres flexible-server create \
    --name $DB_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --admin-user dbadmin \
    --admin-password "$(openssl rand -base64 32)" \
    --sku-name Standard_B1ms \
    --storage-size 32 \
    --version 15

# Створення Storage Account
echo "💾 Створення Storage Account..."
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS

# Створення Web App
echo "🌐 Створення Web App..."
az webapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "${APP_NAME}-plan" \
    --runtime "PYTHON|3.11"

# Налаштування змінних середовища
echo "⚙️ Налаштування змінних середовища..."
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)
DB_HOST=$(az postgres flexible-server show --name $DB_NAME --resource-group $RESOURCE_GROUP --query "fullyQualifiedDomainName" -o tsv)

az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        DJANGO_SETTINGS_MODULE=project_name.settings.production \
        DATABASE_URL="postgresql://dbadmin:password@${DB_HOST}:5432/postgres" \
        AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT \
        AZURE_STORAGE_ACCOUNT_KEY=$STORAGE_KEY \
        SECRET_KEY="$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')"

echo "✅ Розгортання завершено!"
echo "🌐 URL: https://${APP_NAME}.azurewebsites.net"
```

---

## 🔄 CI/CD Pipeline

### `.github/workflows/azure-deploy.yml`

```yaml
name: Deploy to Azure

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AZURE_WEBAPP_NAME: django-portfolio-app
  PYTHON_VERSION: '3.11'

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_USER: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements/testing.txt
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        DJANGO_SETTINGS_MODULE: project_name.settings.testing
      run: |
        python manage.py migrate
        python manage.py test
        pytest --cov=apps/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements/production.txt
    
    - name: Collect static files
      env:
        DJANGO_SETTINGS_MODULE: project_name.settings.production
        SECRET_KEY: temp-secret-for-collectstatic
      run: |
        python manage.py collectstatic --noinput
    
    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: .
```

---

## 📚 Корисні команди

### Розробка в Codespace:
```bash
# Запуск сервера
python manage.py runserver 0.0.0.0:8000

# Міграції
python manage.py makemigrations
python manage.py migrate

# Створення додатка
python manage.py startapp apps/your_app

# Збір статичних файлів
python manage.py collectstatic

# Тестування
python manage.py test
pytest
```

### Azure управління:
```bash
# Вхід в Azure
az login

# Перегляд логів
az webapp log tail --name your-app --resource-group your-rg

# Перезапуск додатка
az webapp restart --name your-app --resource-group your-rg

# Оновлення налаштувань
az webapp config appsettings set --name your-app --resource-group your-rg --settings KEY=VALUE
```

---

## 🔒 Безпека та найкращі практики

1. **Ніколи не комітьте секрети** - використовуйте .env файли
2. **Регулярно оновлюйте залежності** - `pip-audit`
3. **Використовуйте HTTPS** в продакшені
4. **Налаштуйте моніторинг** - Application Insights
5. **Резервне копіювання БД** - автоматичні бекапи Azure
6. **Логування** - централізоване логування в Azure
7. **Secrets management** - Azure Key Vault

---

## 🎯 Результат

Після виконання цього гайду ви матимете:

✅ Повністю налаштоване середовище розробки в GitHub Codespace  
✅ Django додаток з PostgreSQL  
✅ Автоматичний деплой в Azure  
✅ CI/CD pipeline з тестуванням  
✅ Безпечні налаштування для продакшену  
✅ Моніторинг та логування

Цей підхід забезпечує професійний workflow від розробки до продакшену! 🚀


------------------------------------------------------------------------------------------------------------------------------------------------------------------




# 📁 Опис конфігурації .devcontainer для Django проекту

## 🎯 Загальний огляд

Конфігурація `.devcontainer` створює повноцінне середовище розробки Django додатка з PostgreSQL та Redis в GitHub Codespace або VS Code Dev Containers.

---

## 1️⃣ `.devcontainer/devcontainer.json`

### 📝 **Опис:**
Головний конфігураційний файл, що визначає налаштування контейнера розробки.

### 🔧 **Основні секції:**

#### **Базові налаштування:**
```json
{
  "name": "Django PostgreSQL Development",
  "dockerComposeFile": "docker-compose.yml",
  "service": "web",
  "workspaceFolder": "/workspace"
}
```
- **name** - назва середовища розробки
- **dockerComposeFile** - посилання на Docker Compose конфігурацію
- **service** - основний сервіс для розробки (контейнер з Django)
- **workspaceFolder** - робоча папка всередині контейнера

#### **VS Code налаштування:**
```json
"customizations": {
  "vscode": {
    "settings": {
      "python.defaultInterpreterPath": "/usr/local/bin/python",
      "python.linting.enabled": true,
      "python.linting.pylintEnabled": true,
      "python.formatting.provider": "black",
      "python.linting.flake8Enabled": true,
      "python.testing.pytestEnabled": true
    }
  }
}
```
**Призначення:**
- Автоматичне налаштування Python інтерпретатора
- Включення лінтингу (pylint, flake8)
- Налаштування форматування коду (black)
- Активація pytest для тестування
- Приховування __pycache__ файлів

#### **Розширення VS Code:**
```json
"extensions": [
  "ms-python.python",           // Основна підтримка Python
  "ms-python.flake8",           // Лінтинг flake8
  "ms-python.black-formatter",  // Форматування black
  "ms-toolsai.jupyter",         // Jupyter notebooks
  "mtxr.sqltools",              // SQL інструменти
  "mtxr.sqltools-driver-pg",    // PostgreSQL драйвер
  "ms-vscode.vscode-json",      // JSON підтримка
  "bradlc.vscode-tailwindcss",  // TailwindCSS (якщо використовується)
  "formulahendry.auto-rename-tag" // Автоматичне перейменування HTML тегів
]
```

#### **Форвардинг портів:**
```json
"forwardPorts": [8000, 5432],
"portsAttributes": {
  "8000": {
    "label": "Django Development Server",
    "onAutoForward": "notify"
  },
  "5432": {
    "label": "PostgreSQL Database", 
    "onAutoForward": "silent"
  }
}
```
**Що робить:**
- Порт 8000 - Django сервер (з нотифікацією при відкритті)
- Порт 5432 - PostgreSQL (тихий форвардинг)

#### **Lifecycle команди:**
```json
"postCreateCommand": "bash .devcontainer/post-create.sh",
"postAttachCommand": "python manage.py runserver 0.0.0.0:8000"
```
- **postCreateCommand** - виконується після створення контейнера
- **postAttachCommand** - виконується при підключенні до контейнера

#### **Features:**
```json
"features": {
  "ghcr.io/devcontainers/features/azure-cli:1": {},
  "ghcr.io/devcontainers/features/git:1": {}
}
```
- Автоматичне встановлення Azure CLI
- Налаштування Git

---

## 2️⃣ `.devcontainer/docker-compose.yml`

### 📝 **Опис:**
Визначає мульти-контейнерне середовище з Django, PostgreSQL та Redis.

### 🐳 **Сервіси:**

#### **Web сервіс (Django):**
```yaml
web:
  build:
    context: ..
    dockerfile: .devcontainer/Dockerfile
  volumes:
    - ../..:/workspaces:cached
    - /var/run/docker.sock:/var/run/docker.sock
  command: sleep infinity
  environment:
    - DJANGO_SETTINGS_MODULE=project_name.settings.development
    - DATABASE_URL=postgresql://postgres:postgres@db:5432/django_dev
    - DEBUG=True
  depends_on:
    - db
    - redis
  ports:
    - "8000:8000"
```
**Особливості:**
- Збирається з власного Dockerfile
- Монтує проект в `/workspaces`
- Доступ до Docker daemon (для Docker-in-Docker)
- Залежить від db та redis сервісів
- Налаштована на development режим

#### **Database сервіс (PostgreSQL):**
```yaml
db:
  image: postgres:15-alpine
  restart: unless-stopped
  volumes:
    - postgres_data:/var/lib/postgresql/data
  environment:
    POSTGRES_DB: django_dev
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
  ports:
    - "5432:5432"
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 10s
    timeout: 5s
    retries: 5
```
**Особливості:**
- PostgreSQL 15 Alpine (легка версія)
- Persistent дані через volume
- Health check для перевірки готовності
- Стандартні credentials для розробки

#### **Redis сервіс:**
```yaml
redis:
  image: redis:7-alpine
  restart: unless-stopped
  ports:
    - "6379:6379"
```
**Призначення:**
- Кешування Django
- Сесії користувачів
- Черги завдань (Celery)

---

## 3️⃣ `.devcontainer/Dockerfile`

### 📝 **Опис:**
Створює образ контейнера для Django розробки.

### 🔨 **Етапи збірки:**

#### **Базовий образ:**
```dockerfile
FROM python:3.11-slim
```
- Python 3.11 slim версія (мінімальна)

#### **Системні залежності:**
```dockerfile
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*
```
**Встановлює:**
- **postgresql-client** - для роботи з PostgreSQL
- **build-essential** - компілятори для Python пакетів
- **curl** - для завантаження файлів
- **git** - система контролю версій
- **sudo** - для підвищення привілеїв

#### **Створення користувача:**
```dockerfile
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
```
**Що робить:**
- Створює користувача `vscode` з UID/GID 1000
- Дає sudo права без пароля
- Забезпечує правильні дозволи файлів

#### **Python залежності:**
```dockerfile
COPY requirements/development.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/development.txt
USER $USERNAME
```
- Копіює та встановлює development залежності
- Переключається на non-root користувача

---

## 4️⃣ `.devcontainer/post-create.sh`

### 📝 **Опис:**
Скрипт ініціалізації, що виконується після створення контейнера.

### ⚙️ **Кроки виконання:**

#### **1. Встановлення залежностей:**
```bash
pip install -r requirements/development.txt
```
- Встановлює всі Python пакети для розробки

#### **2. Очікування PostgreSQL:**
```bash
echo "Очікування готовності PostgreSQL..."
while ! pg_isready -h db -p 5432 -U postgres; do
  sleep 1
done
```
- Чекає поки PostgreSQL повністю запуститься
- Використовує `pg_isready` для перевірки

#### **3. Застосування міграцій:**
```bash
python manage.py migrate
```
- Створює таблиці бази даних
- Застосовує всі Django міграції

#### **4. Створення суперюзера:**
```bash
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell
```
**Що робить:**
- Створює суперюзера з credentials: admin/admin123
- Перевіряє чи користувач вже існує
- Використовує Django shell для виконання

#### **5. Збір статичних файлів:**
```bash
python manage.py collectstatic --noinput
```
- Збирає CSS, JS, зображення
- Готує для розробки

#### **6. Завершення:**
```bash
echo "🚀 Розробницьке середовище готове!"
```

---

## 🎯 **Результат конфігурації:**

Після запуску Codespace ви отримаєте:

✅ **Повністю налаштоване середовище** з Django, PostgreSQL, Redis  
✅ **VS Code з розширеннями** для Python розробки  
✅ **Автоматичний запуск** Django development server  
✅ **Готову базу даних** з міграціями  
✅ **Суперюзера** для адміністрування  
✅ **Форвардинг портів** для доступу до додатка  
✅ **Azure CLI** для деплою  

## 🚀 **Використання:**

1. Відкрийте репозиторій в GitHub
2. Натисніть **Code** → **Create codespace**
3. Дочекайтесь завершення ініціалізації
4. Відкрийте форвардований порт 8000
5. Почніть розробку!

## ⚠️ **Важливі примітки:**

- **Час ініціалізації:** 3-5 хвилин при першому запуску
- **Credentials:** admin/admin123 (тільки для розробки!)
- **База даних:** Очищується при видаленні Codespace
- **Порти:** 8000 (Django), 5432 (PostgreSQL), 6379 (Redis)
- **Persistent storage:** Тільки через Git commits

Ця конфігурація забезпечує професійне середовище розробки, готове до використання за лічені хвилини! 🎉

--------------------------------------------------------------------------------------------------------------



