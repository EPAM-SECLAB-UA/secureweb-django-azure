
Ось кілька варіантів назв для документації startup.sh:

## 🎯 Рекомендовані назви:

### **Основний варіант:**
```
django-startup-configuration.md
```

### **Альтернативні варіанти:**

**За функціональністю:**
- `app-service-startup-guide.md`
- `django-deployment-startup.md`
- `gunicorn-startup-configuration.md`

**За структурою проекту:**
- `docs/deployment/startup-configuration.md`
- `docs/azure/app-service-startup.md`
- `docs/operations/django-startup-guide.md`

**За категоріями:**
- `azure-app-service-startup.md`
- `production-startup-guide.md`
- `django-gunicorn-startup.md`

## 📁 Рекомендована структура папок:

```
project-root/
├── docs/
│   ├── deployment/
│   │   ├── azure-setup.md
│   │   ├── django-startup-configuration.md  ← ЦЕЙ ФАЙЛ
│   │   └── environment-variables.md
│   ├── azure/
│   │   ├── app-service-startup.md  ← АБО ЦЕЙ
│   │   └── log-analytics-queries.md
│   ├── operations/
│   │   ├── monitoring-setup.md
│   │   └── performance-tuning.md
│   └── README.md
├── startup.sh  ← ACTUAL SCRIPT
└── startup-optimized.sh
```

## 🏷️ Найкращий варіант:

**`docs/deployment/django-startup-configuration.md`**

**Чому саме цей:**
- ✅ Зрозуміло що це про Django startup
- ✅ Вказує на конфігурацію (не просто опис)
- ✅ Категоризовано в deployment папці
- ✅ Легко знайти серед deployment документів
- ✅ Розширюється для різних startup scenarios

## 📋 Рекомендована структура файлу:

```markdown
# Django Startup Configuration

## Overview
Documentation for Django App Service startup scripts and configurations.

## Memory-Optimized Startup (startup.sh)
### Configuration Parameters
### Memory Management
### Gunicorn Settings

## Troubleshooting
### OOM Kill Prevention
### Memory Monitoring
### Performance Tuning

## Environment Variables
### Required Variables
### Optional Settings

## Deployment
### Azure App Service Setup
### Testing Startup Scripts
```

## 🔍 Альтернативи для різних контекстів:

**Якщо фокус на Azure:**
```
azure-app-service-startup.md
```

**Якщо фокус на Gunicorn:**
```
gunicorn-production-config.md
```

**Якщо частина troubleshooting:**
```
startup-troubleshooting-guide.md
```

**Якщо включає всі deployment аспекти:**
```
django-production-deployment.md
```

## 🎯 Спеціалізовані назви:

**Для memory optimization focus:**
```
memory-optimized-startup-guide.md
```

**Для performance tuning:**
```
django-performance-startup.md
```

**Для operations runbook:**
```
django-startup-operations.md
```

**Найпрактичніший варіант:** `docs/deployment/django-startup-configuration.md` 🚀


Ось виправлений скрипт з урахуванням memory issues на B1:

```bash
#!/bin/bash
echo "🚀 Starting Django with PostgreSQL..."

# Exit on any error
set -e

# Перевіряємо підключення до БД
echo "🔍 Testing database connection..."
python manage.py dbshell --command="SELECT version();" || echo "⚠️ Database connection issue"

# Міграції
echo "📊 Running migrations..."
python manage.py migrate --noinput

# Створюємо superuser
echo "👤 Creating superuser..."
python manage.py shell << 'PYTHON_CODE'
import os
from django.contrib.auth import get_user_model
User = get_user_model()
admin_username = os.environ.get('DJANGO_ADMIN_USER', 'admin')
admin_email = os.environ.get('DJANGO_ADMIN_EMAIL', 'admin@company.com')
admin_password = os.environ.get('DJANGO_ADMIN_PASSWORD', 'SecureP@ssw0rd123!')
if not User.objects.filter(username=admin_username).exists():
    User.objects.create_superuser(admin_username, admin_email, admin_password)
    print(f"✅ Superuser '{admin_username}' created")
else:
    print(f"✅ Superuser '{admin_username}' already exists")
PYTHON_CODE

# Збираємо статичні файли
echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

# Force garbage collection before starting server
echo "🧹 Cleaning up memory..."
python -c "import gc; gc.collect(); print('✅ Memory cleanup completed')"

echo "✅ Setup complete! Starting memory-optimized server..."

# Memory-optimized Gunicorn configuration for B1 (1.75GB RAM)
exec gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 1 \
    --worker-class sync \
    --timeout 30 \
    --keepalive 2 \
    --max-requests 500 \
    --max-requests-jitter 50 \
    --preload-app \
    --worker-tmp-dir /dev/shm \
    --access-logfile - \
    --error-logfile - \
    --log-level warning \
    --worker-memory-limit 400000000 \
    project_portfolio.wsgi:application
```

## 🔧 **Ключові зміни для memory optimization:**

### **1. Workers: 2 → 1**
```bash
--workers 1  # Один worker для B1 (1.75GB RAM)
```
**Обґрунтування:** 2 workers на B1 можуть конкурувати за memory

### **2. Timeout: 120 → 30 секунд**
```bash
--timeout 30  # Швидше завершення завислих requests
```
**Ефект:** Зменшення memory leaks від довгих requests

### **3. Додані memory controls:**
```bash
--max-requests 500           # Worker restart кожні 500 requests
--max-requests-jitter 50     # Randomization
--preload-app               # Share memory між workers
--worker-tmp-dir /dev/shm   # Use RAM для temp files
--worker-memory-limit 400000000  # 400MB limit per worker
```

### **4. Logging optimization:**
```bash
--log-level warning  # Менше log output = менше memory
--access-logfile -   # stdout
--error-logfile -    # stderr
```

### **5. Memory cleanup перед стартом:**
```bash
python -c "import gc; gc.collect()"
```

## 🚀 **Альтернативний варіант (ще більш агресивний):**

Якщо OOM kills продовжуються, використайте цю версію:

```bash
#!/bin/bash
echo "🚀 Starting ULTRA memory-optimized Django..."
set -e

# Database check
echo "🔍 Testing database connection..."
python manage.py dbshell --command="SELECT version();" || echo "⚠️ Database connection issue"

# Migrations
echo "📊 Running migrations..."
python manage.py migrate --noinput

# Superuser creation
echo "👤 Creating superuser..."
python manage.py shell << 'PYTHON_CODE'
import os, gc
from django.contrib.auth import get_user_model
User = get_user_model()
admin_username = os.environ.get('DJANGO_ADMIN_USER', 'admin')
admin_email = os.environ.get('DJANGO_ADMIN_EMAIL', 'admin@company.com')
admin_password = os.environ.get('DJANGO_ADMIN_PASSWORD', 'SecureP@ssw0rd123!')
if not User.objects.filter(username=admin_username).exists():
    User.objects.create_superuser(admin_username, admin_email, admin_password)
    print(f"✅ Superuser '{admin_username}' created")
else:
    print(f"✅ Superuser '{admin_username}' already exists")
gc.collect()  # Cleanup after user creation
PYTHON_CODE

# Static files
echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

# Aggressive memory cleanup
echo "🧹 Aggressive memory cleanup..."
python -c "
import gc, os
gc.collect()
if hasattr(gc, 'set_debug'):
    gc.set_debug(gc.DEBUG_UNCOLLECTABLE)
print('✅ Memory optimization completed')
"

echo "✅ Starting ULTRA-optimized server..."

# Ultra-conservative settings
exec gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 1 \
    --worker-class sync \
    --timeout 25 \
    --keepalive 1 \
    --max-requests 300 \
    --max-requests-jitter 30 \
    --preload-app \
    --worker-tmp-dir /dev/shm \
    --access-logfile - \
    --error-logfile - \
    --log-level error \
    --worker-memory-limit 350000000 \
    --graceful-timeout 15 \
    project_portfolio.wsgi:application
```

## 📊 **Очікувані результати:**

### **Memory footprint:**
- **Before:** ~2 workers × 400MB = 800MB + overhead = 1GB+
- **After:** 1 worker × 350MB = 350MB + overhead = ~500MB

### **Stability improvements:**
- Worker restarts кожні 300-500 requests
- Faster timeout (25-30s замість 120s)
- Aggressive memory cleanup
- Shared app memory через preload

## 🎯 **Моніторинг після змін:**

Після deployment перевірте:

```kusto
AppServiceConsoleLogs|search"memory"
```

**Очікуваний результат:** Значно менше або повна відсутність OOM kills! 🚀


## 🎯 **Відмінно! Якщо startup-optimized.sh вже є в репозиторії**

### **Тоді GitHub Actions workflow потрібно спростити:**

## 🛠️ **Спрощений виправлений workflow:**

```yaml
name: Deploy Django to Azure with PostgreSQL (Memory Optimized)

on:
  push:
    branches: [ main, feature/infrastructure-update ]
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: django-app-budget-1752082786
  PYTHON_VERSION: '3.11'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: 🚀 Checkout code
      uses: actions/checkout@v4
      
    - name: 🐍 Set up Python ${{ env.PYTHON_VERSION }}
      uses: actions/setup-python@v5
      with:
        python-version: ${{ env.PYTHON_VERSION }}
        
    - name: 📦 Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        
    - name: 🧪 Run Django checks
      run: |
        python manage.py check --deploy
      env:
        SECRET_KEY: 'github-actions-test-key'
        DEBUG: 'False'
        DB_NAME: ${{ secrets.DB_NAME }}
        DB_USER: ${{ secrets.DB_USER }}
        DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
        DB_HOST: ${{ secrets.DB_HOST }}
        
    - name: 📝 Prepare startup script
      run: |
        # Make startup script executable
        chmod +x startup-optimized.sh
        # Optionally rename to startup.sh for consistency
        cp startup-optimized.sh startup.sh
        
    - name: 🧹 Prepare deployment
      run: |
        find . -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        find . -name "*.pyc" -delete
        rm -rf .git .gitignore README.md docs/ images/ logs/ .env* *.log .vscode/ .devcontainer/
        
    - name: 🚀 Deploy to Azure Web App
      uses: azure/webapps-deploy@v3
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
        package: '.'
        
    - name: ⚙️ Configure App Settings and Startup
      uses: azure/CLI@v1
      with:
        inlineScript: |
          # Set application settings
          az webapp config appsettings set \
            --resource-group django-app-budget-rg \
            --name ${{ env.AZURE_WEBAPP_NAME }} \
            --settings \
              DJANGO_SETTINGS_MODULE="project_portfolio.settings" \
              SECRET_KEY="${{ secrets.DJANGO_SECRET_KEY }}" \
              DEBUG="False" \
              DJANGO_ALLOWED_HOSTS="${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net,.azurewebsites.net,localhost" \
              DB_NAME="${{ secrets.DB_NAME }}" \
              DB_USER="${{ secrets.DB_USER }}" \
              DB_PASSWORD="${{ secrets.DB_PASSWORD }}" \
              DB_HOST="${{ secrets.DB_HOST }}" \
              DB_PORT="5432" \
              SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
              PYTHONPATH="/home/site/wwwroot" \
              DJANGO_ADMIN_USER="admin" \
              DJANGO_ADMIN_EMAIL="admin@company.com" \
              DJANGO_ADMIN_PASSWORD="${{ secrets.DJANGO_ADMIN_PASSWORD }}"
          
          # Set memory-optimized startup command
          echo "📝 Setting memory-optimized startup command..."
          az webapp config set \
            --resource-group django-app-budget-rg \
            --name ${{ env.AZURE_WEBAPP_NAME }} \
            --startup-file "bash startup-optimized.sh"
          
          echo "✅ Memory-optimized startup command configured"
      env:
        AZURE_CREDENTIALS: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
        
    # Rest of the steps remain the same...
```

## 🔑 **Ключові зміни:**

### **1. Видалено створення startup script**
```yaml
# ВИДАЛЕНО: Create memory-optimized startup script
# Використовуємо existing startup-optimized.sh
```

### **2. Додано підготовку існуючого script**
```yaml
- name: 📝 Prepare startup script
  run: |
    chmod +x startup-optimized.sh
    cp startup-optimized.sh startup.sh  # Optional backup
```

### **3. Використання існуючого файлу**
```yaml
--startup-file "bash startup-optimized.sh"
```

## 🎯 **Переваги цього підходу:**

### ✅ **Version control:**
- Startup script версіонується разом з кодом
- Можна відстежувати зміни
- Code review для startup logic

### ✅ **Consistency:**
- Однаковий startup для всіх environments
- Легше debug та troubleshoot
- Можна тестувати локально

### ✅ **Flexibility:**
- Можна створювати різні scripts (development, staging, production)
- Easy rollback до попередніх версій

## 📁 **Рекомендована структура репозиторію:**

```
project-root/
├── startup-optimized.sh          ← Memory-optimized for production
├── startup-development.sh        ← Optional: for local development  
├── startup-staging.sh            ← Optional: for staging environment
├── .github/workflows/deploy.yml  ← Updated workflow
├── manage.py
├── requirements.txt
└── project_portfolio/
```

## 🚀 **Deployment process:**

1. **Commit** оновлений workflow
2. **Push** до `feature/infrastructure-update`
3. **GitHub Actions** automatically:
   - Використає існуючий `startup-optimized.sh`
   - Встановить його як startup command
   - Deploy з memory optimizations

## 🔍 **Перевірка після deployment:**

```kusto
AppServiceConsoleLogs|search"memory"
```

**Очікуваний результат:** Значно менше або відсутність OOM kills! 

**Цей підхід набагато кращий** - використання існуючого версіонованого startup script! 🎯
