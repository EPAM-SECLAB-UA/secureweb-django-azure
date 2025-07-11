Ось кілька варіантів назв для файлу документації:

## 🎯 Рекомендовані назви:

### **Основний варіант:**
```
django-app-troubleshooting-guide.md
```

### **Альтернативні варіанти:**

**За типом проблем:**
- `application-issues-fixes.md`
- `django-memory-optimization-guide.md`
- `app-service-performance-tuning.md`

**За структурою проекту:**
- `docs/troubleshooting/application-level-fixes.md`
- `docs/deployment/production-issues-resolution.md`
- `docs/operations/django-app-maintenance.md`

**За категоріями:**
- `django-production-optimization.md`
- `azure-app-service-debugging.md`
- `performance-memory-fixes.md`

## 📁 Рекомендована структура папок:

```
project-root/
├── docs/
│   ├── deployment/
│   │   ├── azure-setup.md
│   │   └── monitoring-configuration.md
│   ├── troubleshooting/
│   │   ├── django-app-troubleshooting-guide.md  ← ЦЕЙ ФАЙЛ
│   │   ├── memory-optimization.md
│   │   └── performance-tuning.md
│   ├── operations/
│   │   ├── health-checks.md
│   │   └── monitoring-alerts.md
│   └── README.md
```

## 🏷️ Найкращий варіант:

**`docs/troubleshooting/django-app-troubleshooting-guide.md`**

**Чому саме цей:**
- ✅ Зрозуміло з назви про що документ
- ✅ Вказує на технологію (Django)
- ✅ Категоризовано в папці troubleshooting
- ✅ Легко знайти та згадати
- ✅ Слідує стандартам документації

**Альтернатива для простоти:**
```
TROUBLESHOOTING.md
```
(якщо це єдиний troubleshooting документ у проекті)


-------------------------------------------------------------------------------------

## 🎯 План дій для виправлення application-level issues:

### 🔴 **Проблема 1: Memory Issues (Critical)**

**Швидке рішення:**
```bash
# Upgrade App Service Plan
az appservice plan update \
    --name django-app-budget-plan \
    --resource-group django-app-budget-rg \
    --sku B1  # $13/month, 1.75GB RAM
```

**Альтернатива (безкоштовна):**
- Оптимізувати Django settings (connection pooling, cache limits)
- Зменшити кількість Gunicorn workers до 1-2
- Додати memory monitoring middleware

### 🔍 **Проблема 2: Missing Health Endpoint**

**Додати в Django:**
```python
# views.py
def health_check(request):
    return JsonResponse({
        'status': 'healthy',
        'timestamp': timezone.now().isoformat(),
        'checks': {
            'database': check_database(),
            'memory': check_memory()
        }
    })

# urls.py  
path('health/', views.health_check, name='health'),
```

### ⚡ **Проблема 3: Worker Instability**

**Покращити конфігурацію:**
```python
# gunicorn_config.py
workers = 2  # Зменшити кількість
max_requests = 1000  # Перезапуск для memory cleanup
worker_memory_limit = 100 * 1024 * 1024  # 100MB limit
```

## 🚀 **Послідовність дій:**

1. **Негайно (5 хвилин):**
   - Додати health endpoint
   - Deploy нову версію

2. **Короткострокове (сьогодні):**
   - Upgrade App Service Plan або оптимізувати код
   - Додати memory monitoring

3. **Середньострокове (цей тиждень):**
   - Налаштувати custom metrics в Application Insights
   - Створити KQL queries для моніторингу

**Результат:** Стабільна робота без OOM kills та proper health monitoring! 📈

Почнемо з health endpoint - це найшвидше та безкоштовне рішення?

--------------------------------------------------------------------------------------



# 🔧 Виправлення Application-Level Issues в Django App

## 🚨 Виявлені проблеми з логів

### 1. 💾 Memory Issues (OOM Kills)
```bash
Worker (pid:1079) was sent SIGKILL! Perhaps out of memory?
SystemExit: 1
```

### 2. 🔍 Missing Health Endpoint  
```bash
Not Found: /health/
```

### 3. ⚡ Worker Instability
```bash
Worker exiting (pid: 1079)
Booting worker with pid: 2090
```

## 🛠️ Рішення 1: Виправлення Memory Issues

### A. Upgrade App Service Plan
```bash
# Поточний план: Free/Shared (128MB RAM limit)
# Рекомендація: Basic B1 (1.75GB RAM)

az appservice plan update \
    --name django-app-budget-plan \
    --resource-group django-app-budget-rg \
    --sku B1

# Або через Portal:
# App Service Plan → Scale up → Basic B1 ($13/month)
```

### B. Оптимізація Django Settings
```python
# settings.py - Production optimizations

# 1. Database Connection Pooling
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'your_db_name',
        'USER': 'your_db_user',
        'PASSWORD': 'your_db_password',
        'HOST': 'your_db_host',
        'PORT': '5432',
        'OPTIONS': {
            'MAX_CONNS': 20,  # Limit connections
            'MIN_CONNS': 1,
        },
        'CONN_MAX_AGE': 600,  # Connection pooling
    }
}

# 2. Memory-efficient caching
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'OPTIONS': {
            'MAX_ENTRIES': 1000,  # Limit cache size
        }
    }
}

# 3. Limit file upload size
FILE_UPLOAD_MAX_MEMORY_SIZE = 2621440  # 2.5MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 2621440

# 4. Session optimization
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'
SESSION_CACHE_ALIAS = 'default'

# 5. Static files optimization
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# 6. Logging configuration to reduce memory
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'level': 'WARNING',  # Reduce log volume
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}
```

### C. Gunicorn Configuration
```python
# gunicorn_config.py
import multiprocessing

# Worker configuration for memory efficiency
workers = 2  # Reduce from default
worker_class = "sync"
worker_connections = 1000
max_requests = 1000  # Restart workers periodically
max_requests_jitter = 50
preload_app = True  # Save memory by preloading

# Memory limits
worker_memory_limit = 100 * 1024 * 1024  # 100MB per worker
worker_tmp_dir = "/dev/shm"  # Use RAM for tmp files

# Timeouts
timeout = 30
keepalive = 2
graceful_timeout = 30

# Process naming
proc_name = 'django_app'

# Logging
errorlog = '-'
loglevel = 'warning'  # Reduce log verbosity
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'
```

### D. Memory Monitoring Middleware
```python
# middleware/memory_monitor.py
import psutil
import logging
from django.http import JsonResponse

logger = logging.getLogger(__name__)

class MemoryMonitorMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Check memory before request
        memory_before = psutil.virtual_memory().percent
        
        if memory_before > 80:  # If memory > 80%
            logger.warning(f"High memory usage: {memory_before}%")
            
        response = self.get_response(request)
        
        # Check memory after request  
        memory_after = psutil.virtual_memory().percent
        if memory_after > 90:  # Critical threshold
            logger.error(f"Critical memory usage: {memory_after}%")
            
        return response

# settings.py
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'myapp.middleware.memory_monitor.MemoryMonitorMiddleware',  # Add here
    # ... other middleware
]
```

## 🔍 Рішення 2: Додавання Health Endpoint

### A. Створити Health Check View
```python
# views.py
import logging
import psutil
from django.http import JsonResponse
from django.db import connection
from django.core.cache import cache
from django.conf import settings

logger = logging.getLogger(__name__)

def health_check(request):
    """Comprehensive health check endpoint"""
    health_status = {
        'status': 'healthy',
        'timestamp': timezone.now().isoformat(),
        'checks': {}
    }
    
    overall_status = 'healthy'
    
    try:
        # 1. Database connectivity
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            health_status['checks']['database'] = {
                'status': 'healthy',
                'response_time_ms': 0  # You can measure this
            }
    except Exception as e:
        health_status['checks']['database'] = {
            'status': 'unhealthy',
            'error': str(e)
        }
        overall_status = 'unhealthy'
    
    try:
        # 2. Cache connectivity
        cache_key = 'health_check_test'
        cache.set(cache_key, 'test', 10)
        cache_value = cache.get(cache_key)
        
        if cache_value == 'test':
            health_status['checks']['cache'] = {'status': 'healthy'}
        else:
            raise Exception("Cache test failed")
            
    except Exception as e:
        health_status['checks']['cache'] = {
            'status': 'degraded',
            'error': str(e)
        }
    
    # 3. Memory usage
    try:
        memory_percent = psutil.virtual_memory().percent
        health_status['checks']['memory'] = {
            'status': 'healthy' if memory_percent < 80 else 'warning',
            'usage_percent': memory_percent
        }
        
        if memory_percent > 90:
            overall_status = 'unhealthy'
        elif memory_percent > 80:
            overall_status = 'degraded'
            
    except Exception as e:
        health_status['checks']['memory'] = {
            'status': 'unknown',
            'error': str(e)
        }
    
    # 4. Disk space
    try:
        disk_usage = psutil.disk_usage('/')
        disk_percent = (disk_usage.used / disk_usage.total) * 100
        
        health_status['checks']['disk'] = {
            'status': 'healthy' if disk_percent < 80 else 'warning',
            'usage_percent': round(disk_percent, 2)
        }
        
        if disk_percent > 90:
            overall_status = 'unhealthy'
            
    except Exception as e:
        health_status['checks']['disk'] = {
            'status': 'unknown',
            'error': str(e)
        }
    
    # Set overall status
    health_status['status'] = overall_status
    
    # Return appropriate HTTP status
    if overall_status == 'healthy':
        return JsonResponse(health_status, status=200)
    elif overall_status == 'degraded':
        return JsonResponse(health_status, status=200)  # Still accepting traffic
    else:
        return JsonResponse(health_status, status=503)  # Service unavailable

def readiness_check(request):
    """Simple readiness check for load balancer"""
    try:
        # Quick database check
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        return JsonResponse({'status': 'ready'}, status=200)
    except:
        return JsonResponse({'status': 'not ready'}, status=503)

def liveness_check(request):
    """Simple liveness check"""
    return JsonResponse({
        'status': 'alive',
        'timestamp': timezone.now().isoformat()
    }, status=200)
```

### B. Додати URLs
```python
# urls.py
from django.urls import path
from . import views

urlpatterns = [
    # Health checks
    path('health/', views.health_check, name='health_check'),
    path('health/ready/', views.readiness_check, name='readiness_check'),
    path('health/live/', views.liveness_check, name='liveness_check'),
    
    # Your existing URLs
    path('', views.home, name='home'),
    # ...
]
```

## ⚡ Рішення 3: Worker Stability

### A. Startup Script Optimization
```bash
# startup.sh
#!/bin/bash
set -e

echo "Starting Django application..."

# Wait for database
echo "Waiting for database..."
python manage.py wait_for_db

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Run migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Create superuser if needed
echo "Creating superuser..."
python manage.py ensure_superuser

# Start Gunicorn with optimized config
echo "Starting Gunicorn..."
exec gunicorn --config gunicorn_config.py myproject.wsgi:application
```

### B. Database Wait Command
```python
# management/commands/wait_for_db.py
import time
from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError

class Command(BaseCommand):
    help = 'Wait for database to be available'

    def handle(self, *args, **options):
        self.stdout.write('Waiting for database...')
        db_conn = None
        while not db_conn:
            try:
                db_conn = connections['default']
                db_conn.cursor()
            except OperationalError:
                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS('Database available!'))
```

### C. Ensure Superuser Command
```python
# management/commands/ensure_superuser.py
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
import os

User = get_user_model()

class Command(BaseCommand):
    help = 'Create superuser if none exists'

    def handle(self, *args, **options):
        if not User.objects.filter(is_superuser=True).exists():
            username = os.environ.get('DJANGO_SUPERUSER_USERNAME', 'admin')
            email = os.environ.get('DJANGO_SUPERUSER_EMAIL', 'admin@example.com')
            password = os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'changeme123')
            
            User.objects.create_superuser(
                username=username,
                email=email,
                password=password
            )
            self.stdout.write(
                self.style.SUCCESS(f'Superuser {username} created successfully!')
            )
        else:
            self.stdout.write('Superuser already exists')
```

## 🚀 Deployment Process

### 1. Update App Service Configuration
```bash
# Set environment variables
az webapp config appsettings set \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --settings \
    DJANGO_SETTINGS_MODULE=myproject.settings.production \
    DJANGO_SUPERUSER_USERNAME=admin \
    DJANGO_SUPERUSER_EMAIL=admin@yourdomain.com \
    DJANGO_SUPERUSER_PASSWORD=YourSecurePassword123

# Set startup command
az webapp config set \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --startup-file "bash startup.sh"
```

### 2. Deploy Updated Code
```bash
# Option 1: Via Git deployment
git add .
git commit -m "Fix memory issues and add health checks"
git push azure main

# Option 2: Via ZIP deployment
zip -r app.zip . -x "*.git*" "*.pyc" "__pycache__*"
az webapp deployment source config-zip \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --src app.zip
```

### 3. Verify Deployment
```bash
# Test health endpoint
curl https://django-app-budget-1752082786.azurewebsites.net/health/

# Expected response:
{
  "status": "healthy",
  "timestamp": "2025-07-11T07:30:00Z",
  "checks": {
    "database": {"status": "healthy"},
    "cache": {"status": "healthy"},
    "memory": {"status": "healthy", "usage_percent": 45.2},
    "disk": {"status": "healthy", "usage_percent": 23.1}
  }
}
```

## 📊 Monitoring після виправлень

### A. Create Custom KQL Queries
```kusto
// Memory usage tracking
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory usage" or ResultDescription contains "Memory"
| project TimeGenerated, Level, ResultDescription
| order by TimeGenerated desc

// Health check monitoring  
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| where CsUriStem == "/health/"
| summarize 
    Total = count(),
    Healthy = countif(ScStatus == 200),
    Unhealthy = countif(ScStatus == 503)
  by bin(TimeGenerated, 15m)
| extend HealthPercent = (Healthy * 100.0) / Total
```

### B. Set Up Application Insights Custom Metrics
```python
# Add to views.py for custom telemetry
from applicationinsights import TelemetryClient

tc = TelemetryClient('your-instrumentation-key')

def track_memory_usage():
    memory_percent = psutil.virtual_memory().percent
    tc.track_metric('Memory Usage Percent', memory_percent)
    tc.flush()

# Call in health check
def health_check(request):
    track_memory_usage()
    # ... rest of health check code
```

## ✅ Verification Checklist

После всіх змін перевірте:

- [ ] Health endpoint доступний (`/health/`)
- [ ] Memory usage < 80% у нормальних умовах
- [ ] Workers не перезапускаються кожні кілька хвилин
- [ ] Database connections стабільні
- [ ] Application Insights отримує custom metrics
- [ ] Log Analytics показує здорові метрики

## 💰 Cost Impact

```
App Service Plan upgrade (Free → Basic B1):
- Додаткова вартість: ~$13/month
- Переваги: 1.75GB RAM, Custom domains, SSL certificates
- ROI: Зменшення downtime та покращення performance

Alternative (якщо бюджет обмежений):
- Залишити Free tier
- Оптимізувати код максимально
- Додати aggressive caching
- Використовувати CDN для статичних файлів
```

Ці зміни повинні усунути всі application-level issues та забезпечити стабільну роботу Django додатку!

---------------------------------------------------------------------------------------------------------------------------------------

## 🔍 **ВАЖЛИВЕ ВІДКРИТТЯ: Plan вже B1!**

### 📊 **Результат перевірки:**
```
Name: django-app-budget-plan
Tier: Basic
Size: B1  
Capacity: 1
```

### ⚡ **Це змінює всю картину!**

**App Service Plan УЖЕ на Basic B1**, що означає:
- **RAM:** 1.75GB (не 128MB як на Free tier)
- **CPU:** 1 dedicated core
- **Memory per worker:** ~400-500MB available

## 🚨 **Нова діагностика: OOM kills на B1 = серйозні проблеми з кодом**

### **Якщо OOM kills відбуваються на B1, то проблема НЕ в ресурсах:**

#### 1. **Massive Memory Leaks в Django**
```python
# Критичні проблеми:
- Database connection pool overflow
- Infinite cache growth  
- Large objects не збираються garbage collector
- Circular references блокують GC
- Memory-intensive operations без cleanup
```

#### 2. **Неправильна Gunicorn конфігурація**
```python
# Можливі проблеми:
workers = 8  # Занадто багато для 1.75GB
worker_memory_limit = None  # Без лімітів
max_requests = 0  # Workers ніколи не перезапускаються
```

#### 3. **Application-level проблеми**
```python
# Потенційні виклики memory exhaustion:
- Large file uploads без streaming
- Complex querysets без pagination
- Image processing без optimization
- Session data explosion
- Middleware memory accumulation
```

## 🔍 **Негайні дії для діагностики**

### 1. **Перевірити Gunicorn конфігурацію**
```bash
# Подивитися поточну конфігурацію App Service
az webapp config show \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --query "pythonVersion"

# Перевірити startup command
az webapp config show \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --query "appCommandLine"
```

### 2. **Детальний аналіз логів**
```kusto
// Розширений пошук memory-related issues
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory" or 
        ResultDescription contains "Memory" or
        ResultDescription contains "worker" or
        ResultDescription contains "gunicorn" or
        ResultDescription contains "django"
| project TimeGenerated, Level, ResultDescription
| order by TimeGenerated desc
```

### 3. **Перевірити метрики B1 plan**
```bash
# Memory usage на B1
az monitor metrics list \
    --resource "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786" \
    --metric "MemoryWorkingSet" \
    --interval PT1H \
    --output table
```

## 🛠️ **Рекомендовані виправлення для B1**

### **1. Оптимізувати Gunicorn (Priority 1)**
```python
# gunicorn_config.py для B1
import multiprocessing

# Conservative settings for 1.75GB
workers = 2  # Не більше 2 на B1
worker_class = "sync"
worker_connections = 1000
max_requests = 500  # Restart workers часто
max_requests_jitter = 50
preload_app = True  # Share memory

# Memory management
worker_memory_limit = 400 * 1024 * 1024  # 400MB per worker
worker_tmp_dir = "/dev/shm"

# Timeouts
timeout = 30
keepalive = 2
graceful_timeout = 10
```

### **2. Django settings optimization**
```python
# settings.py
# Database connections
DATABASES = {
    'default': {
        # ... your db config
        'CONN_MAX_AGE': 300,  # 5 minutes max
        'OPTIONS': {
            'MAX_CONNS': 10,  # Limit total connections
        }
    }
}

# Cache optimization  
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'OPTIONS': {
            'MAX_ENTRIES': 5000,  # Limit cache size
            'CULL_FREQUENCY': 4,   # Aggressive cleanup
        }
    }
}

# Session optimization
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'
SESSION_CACHE_ALIAS = 'default'
SESSION_COOKIE_AGE = 3600  # 1 hour

# File upload limits
FILE_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 5242880
```

### **3. Memory monitoring middleware**
```python
# middleware/memory_monitor.py
import psutil
import logging
import gc

logger = logging.getLogger(__name__)

class MemoryMonitorMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Pre-request memory check
        memory_before = psutil.virtual_memory().percent
        
        if memory_before > 70:  # Warning threshold
            logger.warning(f"High memory before request: {memory_before}%")
            gc.collect()  # Force garbage collection
        
        response = self.get_response(request)
        
        # Post-request memory check
        memory_after = psutil.virtual_memory().percent
        
        if memory_after > 80:  # Critical threshold
            logger.error(f"Critical memory after request: {memory_after}%")
            gc.collect()
            
        # Log memory growth
        growth = memory_after - memory_before
        if growth > 5:  # 5% growth in single request
            logger.warning(f"High memory growth: {growth}% for {request.path}")
            
        return response
```

## 🎯 **Висновки**

**На B1 tier OOM kills = серйозна проблема з кодом**, не з ресурсами.

**Пріоритети:**
1. **Негайно** - оптимізувати Gunicorn (2 workers max)
2. **Сьогодні** - додати memory monitoring middleware  
3. **Цей тиждень** - профайлити Django код на memory leaks

**B1 повинен бути більш ніж достатньо** для типового Django додатку! 🚀

--------------------------------------------------------------------------------------------------------------------------------------------------


## 🔍 **Аналіз startup команди - Знайшли частину проблеми!**

### 📊 **Поточна конфігурація Gunicorn:**

```bash
gunicorn --bind=0.0.0.0:8000 
         --timeout 300 
         --workers 1 
         --max-requests 1000 
         --max-requests-jitter 100 
         project_portfolio.wsgi:application
```

### ✅ **Хороші налаштування:**
- **workers 1** - правильно для budget setup
- **max-requests 1000** - workers перезапускаються (good for memory cleanup)
- **max-requests-jitter 100** - randomization для уникнення thundering herd

### ⚠️ **Проблемні налаштування:**

#### 1. **Timeout 300 секунд (5 хвилин)**
```bash
--timeout 300  # ЗАНАДТО ВЕЛИКИЙ!
```
**Проблема:** Django requests можуть "зависати" на 5 хвилин, накопичуючи memory
**Рекомендація:** Зменшити до 30-60 секунд

#### 2. **Відсутні memory controls**
```bash
# ВІДСУТНІ:
--worker-memory-limit
--preload-app  
--worker-class
```

## 🛠️ **Оптимізована команда для B1**

### **Рекомендована заміна:**
```bash
# Міграції
python manage.py migrate --noinput

# Збір статичних файлів
python manage.py collectstatic --noinput

# Оптимізований запуск для B1
exec gunicorn --bind=0.0.0.0:8000 \
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
              project_portfolio.wsgi:application
```

### **Обгрунтування змін:**

#### **1. Timeout: 300 → 30 секунд**
```bash
--timeout 30  # Швидше виявлення зависших requests
```
**Ефект:** Requests що споживають багато memory будуть terminated швидше

#### **2. Max-requests: 1000 → 500**
```bash
--max-requests 500  # Частіший restart workers
```
**Ефект:** Memory cleanup кожні 500 requests замість 1000

#### **3. Додані memory optimizations:**
```bash
--preload-app           # Share memory між workers
--worker-tmp-dir /dev/shm  # Use RAM для temp files
--log-level warning     # Менше log output = менше memory
```

## 🚀 **Як оновити конфігурацію**

### **Метод 1: Через Azure CLI**
```bash
# Оновити startup command
az webapp config set \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --startup-file "python manage.py migrate --noinput && python manage.py collectstatic --noinput && exec gunicorn --bind=0.0.0.0:8000 --workers 1 --worker-class sync --timeout 30 --keepalive 2 --max-requests 500 --max-requests-jitter 50 --preload-app --worker-tmp-dir /dev/shm --access-logfile - --error-logfile - --log-level warning project_portfolio.wsgi:application"
```

### **Метод 2: Створити startup script**
```bash
# startup.sh
#!/bin/bash
set -e

echo "Starting Django application..."

# Database setup
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Memory-optimized Gunicorn
exec gunicorn \
    --bind=0.0.0.0:8000 \
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
    project_portfolio.wsgi:application
```

```bash
# Встановити startup script
az webapp config set \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --startup-file "bash startup.sh"
```

## 📊 **Додаткові Django оптимізації**

### **В settings.py додати:**
```python
# Memory-efficient logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'level': 'WARNING',  # Тільки warnings та errors
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}

# Database connection optimization
DATABASES = {
    'default': {
        # ... your config
        'CONN_MAX_AGE': 300,  # 5 minutes
        'OPTIONS': {
            'connect_timeout': 10,
            'options': '-c default_transaction_isolation=read_committed'
        }
    }
}

# Cache optimization
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'OPTIONS': {
            'MAX_ENTRIES': 1000,
            'CULL_FREQUENCY': 4,
        }
    }
}
```

## 🔍 **Очікувані результати**

### **After optimization:**
- **Worker restart frequency:** Кожні 500 requests (замість 1000)
- **Request timeout:** 30 секунд (замість 300)
- **Memory cleanup:** Більш агресивний
- **Shared memory:** preload-app зменшить memory footprint

### **Expected impact:**
```
Before: OOM kills кожні ~55 хвилин
After:  Значно менше OOM kills або повне усунення
Memory usage: Більш стабільний profil
Response times: Більш передбачувані
```

## 🎯 **План дій**

1. **Негайно** - оновити startup command з оптимізаціями
2. **Моніторити** Log Analytics наступні 2-4 години
3. **Перевірити** чи припинилися OOM kills
4. **Fine-tune** параметри якщо потрібно

**Ці зміни повинні значно покращити memory stability на B1!** 🚀

--------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------







