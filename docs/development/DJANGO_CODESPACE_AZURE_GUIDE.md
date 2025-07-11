
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



# 🎯 Ідеальне середовище для професійної розробки Django

## 📋 Архітектура ідеального середовища

```mermaid
graph TB
    A[GitHub Repository] --> B[GitHub Codespace]
    B --> C[Local Development]
    C --> D[Staging Environment]
    D --> E[Production Azure]
    
    B --> F[PostgreSQL Container]
    B --> G[Redis Container]
    B --> H[Django Container]
    
    E --> I[Azure App Service]
    E --> J[Azure PostgreSQL]
    E --> K[Azure Redis]
    E --> L[Azure Storage]
    E --> M[Azure Key Vault]
```

---

## 🏗️ Структура ідеального проекту

```
django-professional-project/
├── 📁 .devcontainer/              # GitHub Codespace конфігурація
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── scripts/
│       ├── post-create.sh
│       ├── post-start.sh
│       └── setup-hooks.sh
├── 📁 .github/                    # CI/CD та автоматизація
│   ├── workflows/
│   │   ├── ci.yml                 # Тестування та лінтинг
│   │   ├── staging-deploy.yml     # Деплой на staging
│   │   ├── production-deploy.yml  # Деплой на production
│   │   └── security-scan.yml      # Безпека
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml
├── 📁 .vscode/                    # VS Code налаштування
│   ├── settings.json
│   ├── launch.json               # Debug конфігурація
│   ├── tasks.json               # Завдання
│   └── extensions.json          # Рекомендовані розширення
├── 📁 apps/                      # Django додатки
│   ├── accounts/                # Користувачі та автентифікація
│   ├── core/                    # Основна логіка
│   ├── api/                     # REST API
│   └── common/                  # Спільні компоненти
├── 📁 config/                    # Проектні налаштування
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   ├── staging.py
│   │   ├── production.py
│   │   └── testing.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── 📁 deployment/                # Деплой скрипти
│   ├── azure/
│   │   ├── infrastructure.bicep  # Infrastructure as Code
│   │   ├── deploy.sh
│   │   └── environments/
│   ├── docker/
│   │   ├── Dockerfile.prod
│   │   └── docker-compose.prod.yml
│   └── scripts/
├── 📁 docs/                      # Документація
│   ├── development.md
│   ├── deployment.md
│   ├── api.md
│   └── troubleshooting.md
├── 📁 frontend/                  # Frontend (якщо потрібно)
│   ├── static/
│   ├── templates/
│   └── assets/
├── 📁 logs/                      # Логи
├── 📁 media/                     # Медіа файли
├── 📁 requirements/              # Python залежності
│   ├── base.txt
│   ├── development.txt
│   ├── staging.txt
│   ├── production.txt
│   └── testing.txt
├── 📁 static/                    # Статичні файли
├── 📁 tests/                     # Тести
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── fixtures/
├── 📁 utils/                     # Утиліти
│   ├── management/
│   └── scripts/
├── 📄 .env.example              # Приклад змінних середовища
├── 📄 .gitignore
├── 📄 .pre-commit-config.yaml   # Pre-commit hooks
├── 📄 docker-compose.yml        # Локальна розробка
├── 📄 manage.py
├── 📄 pyproject.toml            # Python конфігурація
├── 📄 pytest.ini               # Pytest налаштування
├── 📄 README.md
└── 📄 requirements.txt          # Symlink до production
```

---

## ⚙️ Продвинута конфігурація .devcontainer

### 1. `devcontainer.json` - Професійний рівень

```json
{
  "name": "Django Professional Development",
  "dockerComposeFile": "docker-compose.yml",
  "service": "django",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  
  "customizations": {
    "vscode": {
      "settings": {
        // Python налаштування
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.linting.flake8Enabled": true,
        "python.linting.mypyEnabled": true,
        "python.formatting.provider": "black",
        "python.testing.pytestEnabled": true,
        "python.testing.autoTestDiscoverOnSaveEnabled": false,
        
        // Django специфічні налаштування
        "python.linting.pylintArgs": [
          "--load-plugins=pylint_django",
          "--django-settings-module=config.settings.development"
        ],
        
        // Форматування
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.organizeImports": true
        },
        
        // Файли
        "files.exclude": {
          "**/__pycache__": true,
          "**/*.pyc": true,
          "**/node_modules": true,
          "**/.coverage": true
        },
        
        // Git
        "git.enableCommitSigning": true,
        "git.confirmSync": false,
        
        // Terminal
        "terminal.integrated.defaultProfile.linux": "bash",
        "terminal.integrated.profiles.linux": {
          "bash": {
            "path": "/bin/bash",
            "args": ["-l"]
          }
        }
      },
      
      "extensions": [
        // Python Essential
        "ms-python.python",
        "ms-python.flake8",
        "ms-python.black-formatter",
        "ms-python.isort",
        "ms-python.mypy-type-checker",
        "ms-toolsai.jupyter",
        
        // Django
        "batisteo.vscode-django",
        "thebarkman.vscode-djaneiro",
        
        // Database
        "mtxr.sqltools",
        "mtxr.sqltools-driver-pg",
        "cweijan.vscode-postgresql-client2",
        
        // Git & GitHub
        "github.vscode-pull-request-github",
        "github.copilot",
        "github.copilot-chat",
        "eamodio.gitlens",
        
        // Testing
        "ms-python.pytest",
        "hbenl.vscode-test-explorer",
        
        // API Development
        "humao.rest-client",
        "42crunch.vscode-openapi",
        
        // Docker
        "ms-azuretools.vscode-docker",
        
        // Azure
        "ms-vscode.vscode-azurecli",
        "ms-azuretools.vscode-azureappservice",
        
        // Code Quality
        "ms-vscode.vscode-pylance",
        "visualstudioexptteam.vscodeintellicode",
        "streetsidesoftware.code-spell-checker",
        
        // Utilities
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "ms-vscode.powershell",
        "bradlc.vscode-tailwindcss"
      ]
    }
  },
  
  "forwardPorts": [8000, 5432, 6379, 8080, 9000],
  "portsAttributes": {
    "8000": {
      "label": "Django Development Server",
      "onAutoForward": "notify",
      "protocol": "http"
    },
    "5432": {
      "label": "PostgreSQL",
      "onAutoForward": "silent"
    },
    "6379": {
      "label": "Redis",
      "onAutoForward": "silent"
    },
    "8080": {
      "label": "pgAdmin",
      "onAutoForward": "silent",
      "protocol": "http"
    },
    "9000": {
      "label": "Minio (S3 Compatible)",
      "onAutoForward": "silent",
      "protocol": "http"
    }
  },
  
  "postCreateCommand": "bash .devcontainer/scripts/post-create.sh",
  "postStartCommand": "bash .devcontainer/scripts/post-start.sh",
  "postAttachCommand": "bash .devcontainer/scripts/post-attach.sh",
  
  "remoteUser": "vscode",
  "updateRemoteUserUID": true,
  
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/git:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/github-cli:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    }
  },
  
  "mounts": [
    "source=${localWorkspaceFolder}/.vscode-server,target=/home/vscode/.vscode-server,type=bind"
  ]
}
```

### 2. `docker-compose.yml` - Повна інфраструктура

```yaml
version: '3.8'

services:
  django:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
      target: development
    volumes:
      - ../..:/workspaces:cached
      - /var/run/docker.sock:/var/run/docker.sock
      - django_media:/workspace/media
      - django_logs:/workspace/logs
    command: sleep infinity
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/django_dev
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
      - MINIO_ENDPOINT=minio:9000
      - MINIO_ACCESS_KEY=minioadmin
      - MINIO_SECRET_KEY=minioadmin
      - DEBUG=True
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      minio:
        condition: service_started
    ports:
      - "8000:8000"
    networks:
      - django-network

  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    environment:
      POSTGRES_DB: django_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_MULTIPLE_DATABASES: django_dev,django_test
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d django_dev"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - django-network

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - django-network

  pgadmin:
    image: dpage/pgadmin4:latest
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    ports:
      - "8080:80"
    depends_on:
      - postgres
    networks:
      - django-network

  minio:
    image: minio/minio:latest
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    networks:
      - django-network

  celery:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
      target: development
    volumes:
      - ../..:/workspaces:cached
    command: celery -A config worker --loglevel=info --concurrency=2
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/django_dev
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - django-network

  celery-beat:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
      target: development
    volumes:
      - ../..:/workspaces:cached
      - celery_beat_data:/workspace/celerybeat-schedule
    command: celery -A config beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/django_dev
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - django-network

  flower:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
      target: development
    volumes:
      - ../..:/workspaces:cached
    command: celery -A config flower --port=5555
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - CELERY_BROKER_URL=redis://redis:6379/0
    ports:
      - "5555:5555"
    depends_on:
      - redis
    networks:
      - django-network

volumes:
  postgres_data:
  redis_data:
  pgadmin_data:
  minio_data:
  django_media:
  django_logs:
  celery_beat_data:

networks:
  django-network:
    driver: bridge
```

### 3. `Dockerfile` - Мульти-стадійний build

```dockerfile
# Base stage
FROM python:3.11-slim as base

# Встановлення системних залежностей
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    curl \
    git \
    sudo \
    nginx \
    supervisor \
    gettext \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Створення користувача
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Development stage
FROM base as development

# Встановлення Poetry
RUN pip install poetry==1.6.1
RUN poetry config virtualenvs.create false

# Копіювання залежностей
COPY requirements/development.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/development.txt

# Встановлення додаткових інструментів для розробки
RUN pip install \
    ipython \
    ipdb \
    django-debug-toolbar \
    django-extensions \
    factory-boy \
    pytest-django \
    pytest-cov \
    pre-commit

USER $USERNAME

# Production stage
FROM base as production

# Оптимізація для продакшену
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Копіювання та встановлення залежностей
COPY requirements/production.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/production.txt

# Копіювання додатка
COPY . /app
WORKDIR /app

# Збір статичних файлів
RUN python manage.py collectstatic --noinput

# Налаштування Nginx та Supervisor
COPY deployment/docker/nginx.conf /etc/nginx/sites-available/default
COPY deployment/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

---

## 🔧 Професійні налаштування Django

### 1. `config/settings/base.py` - Основа

```python
import os
import sys
from pathlib import Path
from decouple import config
import dj_database_url

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Додавання apps до Python path
sys.path.insert(0, os.path.join(BASE_DIR, 'apps'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config('SECRET_KEY')

# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.sites',
    'django.contrib.sitemaps',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework.authtoken',
    'drf_spectacular',
    'corsheaders',
    'django_filters',
    'django_celery_beat',
    'django_celery_results',
    'storages',
    'crispy_forms',
    'crispy_bootstrap5',
]

LOCAL_APPS = [
    'accounts',
    'core',
    'api',
    'common',
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
    'common.middleware.RequestLoggingMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'frontend' / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'common.context_processors.global_settings',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

# Database
DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL')
    )
}

# Cache
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': config('REDIS_URL', default='redis://localhost:6379/0'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Session storage
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'

# Celery Configuration
CELERY_BROKER_URL = config('CELERY_BROKER_URL', default='redis://localhost:6379/0')
CELERY_RESULT_BACKEND = 'django-db'
CELERY_CACHE_BACKEND = 'django-cache'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = 'Europe/Kiev'

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
USE_L10N = True
USE_TZ = True

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [
    BASE_DIR / 'frontend' / 'static',
]

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom user model
AUTH_USER_MODEL = 'accounts.User'

# Site ID
SITE_ID = 1

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# Spectacular settings (OpenAPI)
SPECTACULAR_SETTINGS = {
    'TITLE': 'Django Professional API',
    'DESCRIPTION': 'Professional Django API with PostgreSQL and Azure deployment',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'django.log',
            'maxBytes': 1024*1024*10,  # 10MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# Crispy Forms
CRISPY_ALLOWED_TEMPLATE_PACKS = 'bootstrap5'
CRISPY_TEMPLATE_PACK = 'bootstrap5'

# Email settings
EMAIL_BACKEND = config('EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')
EMAIL_HOST = config('EMAIL_HOST', default='')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = config('EMAIL_USE_TLS', default=True, cast=bool)
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@example.com')
```

### 2. `config/settings/development.py` - Розробка

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

# Development apps
INSTALLED_APPS += [
    'debug_toolbar',
    'django_extensions',
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
]

# Debug Toolbar
INTERNAL_IPS = [
    '127.0.0.1',
    '0.0.0.0',
]

# CORS для розробки
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# Додаткові налаштування для розробки
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Shell Plus
SHELL_PLUS_PRINT_SQL = True
SHELL_PLUS = 'ipython'

# Email для розробки
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Додаткові debug налаштування
LOGGING['loggers']['django.db.backends']['level'] = 'DEBUG'
```

### 3. `config/settings/production.py` - Продакшн

```python
from .base import *
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.celery import CeleryIntegration

DEBUG = False

ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='').split(',')

# Security settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_PRELOAD = True
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_REFERRER_POLICY = 'same-origin'

# Azure Storage
if config('AZURE_STORAGE_ACCOUNT_NAME', default=None):
    DEFAULT_FILE_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    STATICFILES_STORAGE = 'storages.backends.azure_storage.AzureStaticStorage'
    
    AZURE_STORAGE_ACCOUNT_NAME = config('AZURE_STORAGE_ACCOUNT_NAME')
    AZURE_STORAGE_ACCOUNT_KEY = config('AZURE_STORAGE_ACCOUNT_KEY')
    AZURE_STORAGE_CONTAINER_NAME = config('AZURE_STORAGE_CONTAINER_NAME', default='media')
    AZURE_STATIC_CONTAINER_NAME = config('AZURE_STATIC_CONTAINER_NAME', default='static')

# Database optimizations
DATABASES['default']['CONN_MAX_AGE'] = 600
DATABASES['default']['OPTIONS'] = {
    'sslmode': 'require',
}

# Sentry integration
if config('SENTRY_DSN', default=None):
    sentry_sdk.init(
        dsn=config('SENTRY_DSN'),
        integrations=[
            DjangoIntegration(),
            CeleryIntegration(),
        ],
        traces_sample_rate=0.1,
        send_default_pii=True,
        environment=config('ENVIRONMENT', default='production'),
    )

# Application Insights (Azure)
if config('APPLICATIONINSIGHTS_CONNECTION_STRING', default=None):
    INSTALLED_APPS += ['opencensus.ext.django']
    MIDDLEWARE += ['opencensus.ext.django.middleware.OpencensusMiddleware']
    
    OPENCENSUS = {
        'TRACE': {
            'SAMPLER': 'opencensus.trace.samplers.ProbabilitySampler(rate=0.5)',
            'EXPORTER': f'opencensus.ext.azure.trace_exporter.AzureExporter(connection_string="{config("APPLICATIONINSIGHTS_CONNECTION_STRING")}")',
        }
    }

# Optimized static files
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Email production settings
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# Celery production optimizations
CELERY_TASK_ALWAYS_EAGER = False
CELERY_WORKER_PREFETCH_MULTIPLIER = 1
CELERY_TASK_ACKS_LATE = True
```

---

## 🚀 Автоматизація та CI/CD

### 1. `.github/workflows/ci.yml` - Continuous Integration

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  PYTHON_VERSION: '3.11'
  NODE_VERSION: '18'

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

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
        cache: 'pip'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements/testing.txt

    - name: Run pre-commit hooks
      uses: pre-commit/action@v3.0.0

    - name: Run security checks
      run: |
        bandit -r apps/ config/
        safety check

    - name: Run tests with coverage
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        REDIS_URL: redis://localhost:6379/0
        DJANGO_SETTINGS_MODULE: config.settings.testing
        SECRET_KEY: test-secret-key
      run: |
        python manage.py migrate
        pytest --cov=apps/ --cov-report=xml --cov-report=html
        
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        fail_ci_if_error: true

  lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install flake8 black isort mypy pylint
        
    - name: Run linting
      run: |
        flake8 apps/ config/
        black --check apps/ config/
        isort --check-only apps/ config/
        mypy apps/ config/

  build:
    needs: [test, lint]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build Docker image
      run: |
        docker build -f .devcontainer/Dockerfile --target production -t django-app:latest .
        
    - name: Save Docker image
      run: |
        docker save django-app:latest | gzip > django-app.tar.gz
        
    - name: Upload build artifact
      uses: actions/upload-artifact@v3
      with:
        name: docker-image
        path: django-app.tar.gz
```

### 2. `.github/workflows/staging-deploy.yml` - Staging Deployment

```yaml
name: Deploy to Staging

on:
  push:
    branches: [ develop ]
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: django-app-staging
  RESOURCE_GROUP: django-app-staging-rg

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_STAGING }}
    
    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
        
    - name: Run database migrations
      run: |
        az webapp ssh --name ${{ env.AZURE_WEBAPP_NAME }} --resource-group ${{ env.RESOURCE_GROUP }} --command "python manage.py migrate"
        
    - name: Restart application
      run: |
        az webapp restart --name ${{ env.AZURE_WEBAPP_NAME }} --resource-group ${{ env.RESOURCE_GROUP }}
        
    - name: Run health check
      run: |
        curl -f https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net/health/ || exit 1
```

### 3. `.github/workflows/production-deploy.yml` - Production Deployment

```yaml
name: Deploy to Production

on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'production'
        type: choice
        options:
        - production

env:
  AZURE_WEBAPP_NAME: django-app-prod
  RESOURCE_GROUP: django-app-prod-rg

jobs:
  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Create deployment
      uses: actions/github-script@v6
      id: deployment
      with:
        script: |
          const deployment = await github.rest.repos.createDeployment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.ref,
            environment: 'production',
            auto_merge: false,
            required_contexts: []
          });
          return deployment.data.id;
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_PRODUCTION }}
    
    - name: Deploy Infrastructure
      run: |
        az deployment group create \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --template-file deployment/azure/infrastructure.bicep \
          --parameters environment=production
    
    - name: Deploy Application
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
        
    - name: Run database migrations
      run: |
        az webapp ssh --name ${{ env.AZURE_WEBAPP_NAME }} --resource-group ${{ env.RESOURCE_GROUP }} --command "python manage.py migrate"
        
    - name: Warm up application
      run: |
        curl -f https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net/health/
        
    - name: Update deployment status (success)
      if: success()
      uses: actions/github-script@v6
      with:
        script: |
          await github.rest.repos.createDeploymentStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            deployment_id: ${{ steps.deployment.outputs.result }},
            state: 'success',
            environment_url: 'https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net'
          });
          
    - name: Update deployment status (failure)
      if: failure()
      uses: actions/github-script@v6
      with:
        script: |
          await github.rest.repos.createDeploymentStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            deployment_id: ${{ steps.deployment.outputs.result }},
            state: 'failure'
          });
```

---

## 🔒 Безпека та якість коду

### 1. `.pre-commit-config.yaml` - Pre-commit hooks

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        additional_dependencies: [flake8-docstrings, flake8-import-order]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.3.0
    hooks:
      - id: mypy
        additional_dependencies: [django-stubs, djangorestframework-stubs]

  - repo: https://github.com/pycqa/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ['-r', 'apps/', 'config/']

  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.2
    hooks:
      - id: python-safety-dependencies-check

  - repo: https://github.com/Riverside-Healthcare/djLint
    rev: v1.31.1
    hooks:
      - id: djlint-reformat-django
      - id: djlint-django
```

### 2. `pyproject.toml` - Python конфігурація

```toml
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
  | migrations
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
known_first_party = ["apps", "config"]
known_django = "django"
known_third_party = ["rest_framework", "celery"]
sections = ["FUTURE", "STDLIB", "DJANGO", "THIRDPARTY", "FIRSTPARTY", "LOCALFOLDER"]

[tool.mypy]
python_version = "3.11"
check_untyped_defs = true
ignore_missing_imports = true
warn_unused_ignores = true
warn_redundant_casts = true
warn_unused_configs = true
plugins = ["mypy_django_plugin.main", "mypy_drf_plugin.main"]

[tool.django-stubs]
django_settings_module = "config.settings.development"

[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.testing"
python_files = ["tests.py", "test_*.py", "*_tests.py"]
addopts = "--cov=apps --cov-report=html --cov-report=term-missing --cov-fail-under=80"

[tool.coverage.run]
source = "apps"
omit = [
    "*/migrations/*",
    "*/tests/*",
    "*/venv/*",
    "*/env/*",
    "manage.py",
    "config/wsgi.py",
    "config/asgi.py"
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError"
]
```

---

## ☁️ Azure Infrastructure as Code

### 1. `deployment/azure/infrastructure.bicep` - Bicep template

```bicep
@description('Environment name')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App name prefix')
param appName string = 'django-app'

var resourceSuffix = '${appName}-${environment}'
var webAppName = '${resourceSuffix}-webapp'
var appServicePlanName = '${resourceSuffix}-asp'
var postgresServerName = '${resourceSuffix}-postgres'
var redisName = '${resourceSuffix}-redis'
var storageAccountName = replace('${resourceSuffix}storage', '-', '')
var keyVaultName = '${resourceSuffix}-kv'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: environment == 'production' ? 'P1v2' : 'B1'
    tier: environment == 'production' ? 'PremiumV2' : 'Basic'
  }
  properties: {
    reserved: true
  }
  kind: 'linux'
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: environment == 'production'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'DJANGO_SETTINGS_MODULE'
          value: 'config.settings.${environment}'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '7'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresServerName
  location: location
  sku: {
    name: environment == 'production' ? 'Standard_D2s_v3' : 'Standard_B1ms'
    tier: environment == 'production' ? 'GeneralPurpose' : 'Burstable'
  }
  properties: {
    version: '15'
    administratorLogin: 'dbadmin'
    administratorLoginPassword: 'TempPassword123!'
    storage: {
      storageSizeGB: environment == 'production' ? 128 : 32
    }
    backup: {
      backupRetentionDays: environment == 'production' ? 30 : 7
      geoRedundantBackup: environment == 'production' ? 'Enabled' : 'Disabled'
    }
    highAvailability: {
      mode: environment == 'production' ? 'ZoneRedundant' : 'Disabled'
    }
  }
}

// PostgreSQL Database
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  parent: postgresServer
  name: 'django_${environment}'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

// Redis Cache
resource redisCache 'Microsoft.Cache/redis@2023-04-01' = {
  name: redisName
  location: location
  properties: {
    sku: {
      name: environment == 'production' ? 'Premium' : 'Basic'
      family: environment == 'production' ? 'P' : 'C'
      capacity: environment == 'production' ? 1 : 0
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: environment == 'production' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: environment == 'production'
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourceSuffix}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${resourceSuffix}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'production' ? 90 : 30
  }
}

// Outputs
output webAppName string = webApp.name
output postgresServerName string = postgresServer.name
output redisName string = redisCache.name
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
```

---

## 📊 Моніторинг та логування

### 1. Налаштування Application Insights

```python
# config/settings/base.py - додати
if config('APPLICATIONINSIGHTS_CONNECTION_STRING', default=None):
    INSTALLED_APPS += [
        'opencensus.ext.django',
    ]
    
    MIDDLEWARE += [
        'opencensus.ext.django.middleware.OpencensusMiddleware',
    ]
    
    OPENCENSUS = {
        'TRACE': {
            'SAMPLER': 'opencensus.trace.samplers.ProbabilitySampler(rate=1.0)',
            'EXPORTER': f'''opencensus.ext.azure.trace_exporter.AzureExporter(
                connection_string="{config('APPLICATIONINSIGHTS_CONNECTION_STRING')}"
            )''',
        }
    }
```

### 2. Custom middleware для логування

```python
# apps/common/middleware.py
import logging
import time
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware(MiddlewareMixin):
    def process_request(self, request):
        request.start_time = time.time()
        
    def process_response(self, request, response):
        if hasattr(request, 'start_time'):
            duration = time.time() - request.start_time
            logger.info(
                f"{request.method} {request.path} - "
                f"{response.status_code} - {duration:.3f}s"
            )
        return response
```

---

## 🎯 Фінальні рекомендації

### 1. **Безпека**
- Використовуйте Azure Key Vault для секретів
- Налаштуйте HTTPS для всіх середовищ
- Регулярно оновлюйте залежності
- Використовуйте Managed Identity

### 2. **Продуктивність**
- Налаштуйте Redis для кешування
- Використовуйте CDN для статичних файлів
- Оптимізуйте запити до БД
- Налаштуйте автоматичне масштабування

### 3. **Моніторинг**
- Application Insights для метрик
- Structured logging
- Health checks
- Алерти для критичних метрик

### 4. **Процеси розробки**
- Git Flow або GitHub Flow
- Code review обов'язковий
- Автоматичне тестування
- Поетапний деплой (dev → staging → production)

Це середовище забезпечує професійний рівень розробки з автоматизацією, безпекою та масштабованістю! 🚀

---------------------------------------------------

