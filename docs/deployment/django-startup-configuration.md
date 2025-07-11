
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
