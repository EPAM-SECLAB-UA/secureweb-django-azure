# 📁 Документація Django Settings

## Файл: `project_portfolio/settings.py`

Центральний конфігураційний файл Django застосунку з підтримкою багатосередовищної архітектури, Azure Key Vault інтеграції та розумного fallback механізму.

## 🎯 Призначення

Цей файл налаштувань забезпечує:
- **Multi-environment support** - автоматичне виявлення та налаштування для різних середовищ
- **Azure Key Vault інтеграція** - безпечне зберігання секретів у хмарі
- **Intelligent fallback** - graceful degradation при відсутності ресурсів
- **Development-friendly** - оптимізований для розробки у GitHub Codespace

## 🌍 Підтримувані середовища

### Автоматичне виявлення середовища
```python
def detect_environment():
    if os.environ.get('CODESPACES'):
        return 'codespace'           # GitHub Codespace
    elif os.environ.get('GITHUB_ACTIONS'):
        return 'github_actions'      # GitHub Actions CI/CD
    elif os.environ.get('WEBSITE_SITE_NAME'):
        return 'azure_app_service'   # Azure App Service
    elif os.environ.get('DYNO'):
        return 'heroku'             # Heroku
    else:
        return 'local'              # Local development
```

### Специфічні налаштування по середовищах

| Середовище | DEBUG | ALLOWED_HOSTS | Database | Email | Logging |
|------------|-------|---------------|----------|-------|---------|
| **Codespace** | `True` | `['*']` | SQLite/PostgreSQL | Console | Minimal |
| **Local** | Variable | Limited | PostgreSQL/SQLite | SMTP/Console | Full |
| **Azure App Service** | `False` | Azure domains | PostgreSQL | SMTP | Full |
| **GitHub Actions** | Variable | CI-specific | PostgreSQL | Console | CI-optimized |

## 🔐 Azure Key Vault Integration

### Архітектура безпеки
```python
# Пріоритет отримання секретів:
# 1. Environment Variables (Codespace/CI)
# 2. Azure Key Vault (Production)
# 3. Default values (Development)

@lru_cache(maxsize=128)
def get_secret(secret_name, default=None):
    # Cached retrieval для performance
```

### Підтримувані методи автентифікації
- **Service Principal** - для CI/CD та Codespace
- **Managed Identity** - для Azure App Service
- **Azure CLI** - для локальної розробки
- **Environment Variables** - fallback для всіх

### Секрети що підтримуються
| Категорія | Секрети | Опис |
|-----------|---------|------|
| **Django Core** | `django-secret-key`, `django-debug-{env}` | Основні Django налаштування |
| **Database** | `database-password`, `postgres-*` | PostgreSQL credentials |
| **Email** | `email-host-*`, `sendgrid-api-key` | Email сервіси |
| **Azure Services** | `azure-storage-*`, `redis-*` | Azure інтеграції |
| **Security** | `jwt-secret-key`, `csrf-cookie-secret` | Криптографічні ключі |

## 🗄️ Database Configuration

### Intelligent Database Selection
```python
def get_database_config():
    # 1. Test PostgreSQL connectivity
    # 2. Fallback to SQLite if unavailable
    # 3. Environment-specific SSL settings
```

### Підтримувані конфігурації
- **PostgreSQL** - primary для production
- **SQLite** - fallback для development
- **Connection testing** - автоматична перевірка доступності
- **SSL/TLS** - автоматичне налаштування по середовищах

### Connection Pool Settings
```python
# Production optimizations
'CONN_MAX_AGE': 600,
'CONN_HEALTH_CHECKS': True,
'OPTIONS': {
    'sslmode': 'require',  # Production
    'connect_timeout': 60,
}
```

## 📧 Email Configuration

### Adaptive Email Backend
- **Codespace/Debug**: Console backend (development)
- **Production**: SMTP backend з Key Vault credentials
- **Fallback**: Local SMTP settings

### Підтримувані провайдери
- **Gmail SMTP** - стандартний SMTP
- **SendGrid** - API integration через Key Vault
- **Console** - development режим

## 🎨 Static & Media Files

### Static Files Strategy
```python
# Dynamic STATICFILES_DIRS based on existence
static_dirs_to_check = [
    BASE_DIR / 'static',
    BASE_DIR / 'project_portfolio' / 'static',
]
```

### Azure Storage Integration
- **Production**: Azure Blob Storage для static/media
- **Development**: Local file system
- **Auto-detection**: Based on environment і Key Vault secrets

## 🔒 Security Settings

### Environment-based Security
```python
# Production security hardening
if ENVIRONMENT in ['staging', 'prod', 'production']:
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
```

### CSRF Protection для Codespace
```python
# Dynamic CSRF trusted origins
if RUNTIME_ENVIRONMENT == 'codespace':
    CSRF_TRUSTED_ORIGINS = [
        f'https://{codespace_name}-8000.{codespace_domain}'
    ]
```

## 📝 Templates Configuration

### Multi-directory Template Support
```python
TEMPLATES = [{
    'DIRS': [
        BASE_DIR / 'templates',                    # Global templates
        BASE_DIR / 'project_portfolio' / 'templates',  # App-specific
    ],
}]
```

### Supported Template Locations
- **Root templates/** - глобальні templates
- **App templates/** - app-specific templates
- **Auto-discovery** - через APP_DIRS

## 🚀 Performance Optimizations

### Caching Strategy
- **Codespace**: Local memory cache
- **Production**: Redis through Key Vault
- **Fallback**: Local memory cache

### Secret Caching
```python
@lru_cache(maxsize=128)
def get_secret(secret_name, default=None):
    # Reduces Key Vault API calls
```

### Database Connection Pooling
- **Connection reuse**: CONN_MAX_AGE = 600
- **Health checks**: Automatic connection validation
- **Timeout protection**: Connect timeout = 60s

## 🛠️ Development Features

### GitHub Codespace Optimizations
- **Auto-reload**: Browser refresh on file changes
- **Port forwarding**: Automatic CSRF origins
- **Reduced logging**: Minimal noise в development
- **PostgreSQL detection**: Auto-fallback до SQLite

### Debug Enhancements
```python
# Codespace-specific debug tools
if DEBUG and RUNTIME_ENVIRONMENT in ['codespace', 'local']:
    try:
        import django_browser_reload
        INSTALLED_APPS.append('django_browser_reload')
    except ImportError:
        pass
```

## 📊 Logging Configuration

### Environment-adaptive Logging
- **Codespace**: Simplified console output
- **Production**: Structured logging з timestamps
- **CI/CD**: Optimized для automated processing

### Log Levels
- **DEBUG**: Development detailed info
- **INFO**: Production operational info
- **WARNING**: Fallback notifications
- **ERROR**: Critical issues

## ⚙️ Configuration Variables

### Environment Variables Support
| Variable | Description | Default | Environments |
|----------|-------------|---------|--------------|
| `SECRET_KEY` | Django secret key | Generated | All |
| `DEBUG` | Debug mode flag | `True` | Local/Codespace |
| `DATABASE_URL` | Full database URL | None | Production |
| `KEY_VAULT_URL` | Azure Key Vault URL | Dev vault | Production |
| `AZURE_CLIENT_ID` | Service Principal ID | None | CI/CD |

### Key Vault Environment Variables
```bash
# Service Principal Authentication
AZURE_CLIENT_ID="your-service-principal-id"
AZURE_CLIENT_SECRET="your-service-principal-secret"
AZURE_TENANT_ID="your-azure-tenant-id"

# Key Vault Configuration
KEY_VAULT_URL="https://your-keyvault.vault.azure.net/"
```

## 🔧 Maintenance and Updates

### Adding New Secrets
1. **Add to Key Vault** через Azure Portal або CLI
2. **Update get_secret() calls** в settings.py
3. **Add fallback defaults** для development
4. **Test in all environments**

### Environment-specific Overrides
```python
# Add environment-specific logic
if RUNTIME_ENVIRONMENT == 'your_new_environment':
    # Custom configuration
    pass
```

### Database Migration Strategy
```python
# For new database configurations
def get_database_config():
    # Add new connection testing
    # Implement graceful fallbacks
    # Maintain backward compatibility
```

## 🚨 Security Considerations

### Secrets Management
- ✅ **Never commit secrets** to version control
- ✅ **Use Key Vault** for production secrets
- ✅ **Rotate secrets regularly**
- ✅ **Principle of least privilege**

### Production Hardening
- ✅ **SSL/TLS enforcement**
- ✅ **HSTS headers**
- ✅ **Secure cookies**
- ✅ **CSRF protection**

### Development Safety
- ✅ **Debug mode protection**
- ✅ **Default secret warnings**
- ✅ **Environment isolation**

## 📋 Troubleshooting

### Common Issues

#### Key Vault Access Denied
```bash
# Check Azure credentials
az account show
az keyvault secret list --vault-name your-vault
```

#### Database Connection Failed
```bash
# Test PostgreSQL connectivity
python -c "import socket; socket.create_connection(('host', 5432), 2)"
```

#### Template Not Found
```bash
# Verify template directories
ls -la templates/
ls -la project_portfolio/templates/
```

### Debug Commands
```python
# In Django shell
from django.conf import settings
print("Environment:", settings.RUNTIME_ENVIRONMENT)
print("Database:", settings.DATABASES['default']['ENGINE'])
print("Templates:", settings.TEMPLATES[0]['DIRS'])
```

## 🔄 Migration Guide

### From Basic Settings
1. **Backup existing settings.py**
2. **Install Azure SDK**: `pip install azure-keyvault-secrets azure-identity`
3. **Replace settings.py** with this version
4. **Configure Key Vault** or use environment variables
5. **Test in development** before production deployment

### Breaking Changes
- **Template directories**: Now supports multiple paths
- **Database config**: Auto-detection може змінити database
- **Secret retrieval**: Caching може змінити behavior
- **Logging**: Reduced output в Codespace

## 📁 Рекомендовані файли для збереження документації

### 1. **docs/settings.md** (рекомендовано)
```
project_root/
├── docs/
│   ├── settings.md          # Ця документація
│   ├── deployment.md        # Deployment guide
│   ├── keyvault-setup.md    # Key Vault configuration
│   └── development.md       # Development workflow
```

### 2. **README-settings.md** (альтернатива)
```
project_root/
├── README.md               # Main project README
├── README-settings.md      # Settings documentation
└── project_portfolio/
    └── settings.py         # Actual settings file
```

### 3. **Inline документація** (додатково)
```python
# project_portfolio/settings.py
"""
Django Settings Documentation

See docs/settings.md for detailed configuration guide.
Environment detection: auto
Key Vault integration: enabled
Multi-database support: PostgreSQL/SQLite
"""
```

### 4. **Wiki або Documentation Site**
- **GitHub Wiki** - для open source projects
- **GitBook** - для detailed documentation
- **Sphinx** - для Python projects з autodoc

## 💡 Best Practices

### Файлова структура документації
```
docs/
├── README.md              # Documentation index
├── settings.md            # This file
├── api/
│   ├── authentication.md  # Auth documentation
│   └── endpoints.md       # API endpoints
├── deployment/
│   ├── azure.md          # Azure deployment
│   ├── local.md          # Local setup
│   └── ci-cd.md          # Pipeline setup
└── troubleshooting/
    ├── common-issues.md   # FAQ
    └── debugging.md       # Debug guide
```

**Рекомендація**: Використовуйте `docs/settings.md` як основний файл документації з посиланнями на інші розділи для повної картини архітектури проекту.


```python

"""
Django settings for project_portfolio project.

Generated by 'django-admin startproject' using Django 5.0.4.

For more information on this file, see
https://docs.djangoproject.com/en/5.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.0/topics/settings/
"""

import os
import logging
from pathlib import Path
from functools import lru_cache

# Azure Key Vault imports
try:
    from azure.keyvault.secrets import SecretClient
    from azure.identity import DefaultAzureCredential, ClientSecretCredential
    AZURE_AVAILABLE = True
except ImportError:
    AZURE_AVAILABLE = False
    # У Codespace не показуємо warning
    if not os.environ.get('CODESPACES'):
        logging.warning("Azure SDK not installed. Falling back to environment variables.")

# Legacy support for decouple (можна видалити пізніше)
try:
    from decouple import config
    DECOUPLE_AVAILABLE = True
except ImportError:
    DECOUPLE_AVAILABLE = False
    # Fallback функція
    def config(key, default=None, cast=None):
        value = os.environ.get(key, default)
        if cast and value is not None:
            return cast(value)
        return value

# Build paths inside the project
BASE_DIR = Path(__file__).resolve().parent.parent

# Logger configuration
logger = logging.getLogger(__name__)

# Environment detection
def detect_environment():
    """Визначає середовище виконання"""
    if os.environ.get('CODESPACES') or os.environ.get('CODESPACE_NAME'):
        return 'codespace'
    elif os.environ.get('GITHUB_ACTIONS'):
        return 'github_actions'
    elif os.environ.get('WEBSITE_SITE_NAME'):  # Azure App Service
        return 'azure_app_service'
    elif os.environ.get('DYNO'):  # Heroku
        return 'heroku'
    else:
        return 'local'

RUNTIME_ENVIRONMENT = detect_environment()
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')

# Key Vault configuration
KEY_VAULT_URL = os.environ.get('KEY_VAULT_URL', 'https://django-app-dev-kv.vault.azure.net/')

# Тільки логуємо якщо не в Codespace (щоб зменшити шум)
if RUNTIME_ENVIRONMENT != 'codespace':
    logger.info(f"Runtime environment: {RUNTIME_ENVIRONMENT}")
    logger.info(f"Application environment: {ENVIRONMENT}")

def get_azure_credential():
    """Отримує Azure credentials залежно від середовища"""
    if RUNTIME_ENVIRONMENT == 'codespace':
        # У Codespace використовуємо Service Principal
        client_id = os.environ.get('AZURE_CLIENT_ID')
        client_secret = os.environ.get('AZURE_CLIENT_SECRET')
        tenant_id = os.environ.get('AZURE_TENANT_ID')
        
        if all([client_id, client_secret, tenant_id]):
            logger.info("Using Service Principal authentication for Codespace")
            return ClientSecretCredential(
                tenant_id=tenant_id,
                client_id=client_id,
                client_secret=client_secret
            )
        else:
            # У Codespace не логуємо warning при кожному виклику
            return None
    
    elif RUNTIME_ENVIRONMENT == 'azure_app_service':
        # В Azure App Service використовуємо Managed Identity
        logger.info("Using Managed Identity authentication")
        return DefaultAzureCredential()
    
    elif RUNTIME_ENVIRONMENT == 'local':
        # Локально використовуємо Azure CLI
        logger.info("Using DefaultAzureCredential for local development")
        return DefaultAzureCredential()
    
    else:
        if RUNTIME_ENVIRONMENT != 'codespace':
            logger.warning(f"No Azure authentication for environment: {RUNTIME_ENVIRONMENT}")
        return None

@lru_cache(maxsize=128)
def get_secret(secret_name, default=None):
    """
    Отримує секрет з різних джерел залежно від середовища
    
    Пріоритет:
    1. Environment variables (для Codespace/CI)
    2. Azure Key Vault (для Azure/production)
    3. Default value
    """
    # Для Codespace та інших CI/CD середовищ - спочатку environment variables
    if RUNTIME_ENVIRONMENT in ['codespace', 'github_actions']:
        env_variations = [
            secret_name.upper().replace('-', '_'),  # DATABASE_PASSWORD
            f"KV_{secret_name.upper().replace('-', '_')}",  # KV_DATABASE_PASSWORD
            secret_name.replace('-', '_'),  # database_password
            secret_name.upper(),  # DATABASE-PASSWORD
        ]
        
        for env_key in env_variations:
            env_value = os.environ.get(env_key)
            if env_value:
                if RUNTIME_ENVIRONMENT != 'codespace':
                    logger.debug(f"Using environment variable {env_key} for {secret_name}")
                return env_value
    
    # Якщо Azure SDK недоступний
    if not AZURE_AVAILABLE:
        if RUNTIME_ENVIRONMENT != 'codespace':
            logger.warning(f"Azure SDK unavailable, using default for {secret_name}")
        return default
    
    # Спробуємо Key Vault
    credential = get_azure_credential()
    if not credential:
        if RUNTIME_ENVIRONMENT != 'codespace':
            logger.warning(f"No Azure credentials, using default for {secret_name}")
        return default
    
    try:
        client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)
        secret = client.get_secret(secret_name)
        logger.debug(f"Retrieved secret {secret_name} from Key Vault")
        return secret.value
        
    except Exception as e:
        if RUNTIME_ENVIRONMENT != 'codespace':
            logger.error(f"Error retrieving secret {secret_name} from Key Vault: {e}")
        return default

# Legacy функція для сумісності
def get_secret_legacy(secret_name):
    """Legacy функція для сумісності з існуючим кодом"""
    try:
        return get_secret(secret_name)
    except Exception as e:
        if RUNTIME_ENVIRONMENT != 'codespace':
            print(f"Помилка отримання секрету {secret_name}: {e}")
        return None

# =============================================================================
# CORE DJANGO SETTINGS
# =============================================================================

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = get_secret('django-secret-key', 'dev-secret-key-change-in-production')

# SECURITY WARNING: don't run with debug turned on in production!
if RUNTIME_ENVIRONMENT == 'codespace':
    DEBUG = True  # Завжди True в Codespace
else:
    DEBUG = get_secret(f'django-debug-{ENVIRONMENT}', 'true').lower() == 'true'

# Allowed hosts configuration
def get_allowed_hosts():
    """Конфігурує ALLOWED_HOSTS залежно від середовища"""
    
    # Отримуємо з Key Vault або environment
    kv_allowed_hosts = get_secret('django-allowed-hosts')
    env_allowed_hosts = os.environ.get('DJANGO_ALLOWED_HOSTS')
    
    allowed_hosts = []
    
    if kv_allowed_hosts:
        allowed_hosts.extend([host.strip() for host in kv_allowed_hosts.split(',')])
    elif env_allowed_hosts:
        allowed_hosts.extend([host.strip() for host in env_allowed_hosts.split(',')])
    
    # Додаємо специфічні хости для кожного середовища
    if RUNTIME_ENVIRONMENT == 'codespace':
        allowed_hosts.extend([
            'localhost',
            '127.0.0.1',
            '0.0.0.0',
            '.githubpreview.dev',
            '.github.dev',
            '.app.github.dev',
            '*',  # У dev середовищі дозволяємо все
        ])
    elif RUNTIME_ENVIRONMENT == 'azure_app_service':
        # Azure App Service хости
        site_name = os.environ.get('WEBSITE_SITE_NAME')
        if site_name:
            allowed_hosts.extend([
                f'{site_name}.azurewebsites.net',
                '.azurewebsites.net',
            ])
    
    # Базові хости для всіх середовищ
    allowed_hosts.extend([
        'django-app-budget-1752082786.azurewebsites.net',
        '.azurewebsites.net',
        'localhost',
        '127.0.0.1'
    ])
    
    # Видаляємо дублікати та пусті значення
    return list(filter(None, set(allowed_hosts)))

ALLOWED_HOSTS = get_allowed_hosts()

# CSRF trusted origins для Codespace
CSRF_TRUSTED_ORIGINS = []
if RUNTIME_ENVIRONMENT == 'codespace':
    codespace_name = os.environ.get("CODESPACE_NAME")
    codespace_domain = os.environ.get("GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN")
    if codespace_name and codespace_domain:
        CSRF_TRUSTED_ORIGINS = [f'https://{codespace_name}-8000.{codespace_domain}']

# X-Frame options для GitHub preview
X_FRAME_OPTIONS = "ALLOW-FROM preview.app.github.dev"

# =============================================================================
# APPLICATION DEFINITION
# =============================================================================

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

# Додаємо browser reload тільки в development
if DEBUG and RUNTIME_ENVIRONMENT in ['codespace', 'local']:
    try:
        import django_browser_reload
        INSTALLED_APPS.append('django_browser_reload')
    except ImportError:
        pass

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Додаємо browser reload middleware тільки в development
if DEBUG and 'django_browser_reload' in INSTALLED_APPS:
    MIDDLEWARE.append('django_browser_reload.middleware.BrowserReloadMiddleware')

ROOT_URLCONF = 'project_portfolio.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            BASE_DIR / 'templates',  # Папка templates в корені проекту
            BASE_DIR / 'project_portfolio' / 'templates',  # Папка в додатку
        ],
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

WSGI_APPLICATION = 'project_portfolio.wsgi.application'

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

def test_postgres_connection(host, port):
    """Тестує підключення до PostgreSQL"""
    try:
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)  # 2 секунди timeout
        result = sock.connect_ex((host, int(port)))
        sock.close()
        return result == 0
    except:
        return False

def get_codespace_database_config():
    """PostgreSQL конфігурація для Codespace з тестуванням підключення"""
    codespace_configs = [
        {
            'host': os.environ.get('POSTGRES_HOST', 'localhost'),
            'port': os.environ.get('POSTGRES_PORT', '5432'),
            'name': os.environ.get('POSTGRES_DB', 'postgres'),
            'user': os.environ.get('POSTGRES_USER', 'postgres'),
            'password': os.environ.get('POSTGRES_PASSWORD'),
        },
        {
            'host': 'db',
            'port': '5432',
            'name': 'project_portfolio',
            'user': 'django_user',
            'password': 'django_password',
        },
        {
            'host': 'postgres',
            'port': '5432',
            'name': 'django_dev',
            'user': 'django',
            'password': 'password',
        },
    ]
    
    for config in codespace_configs:
        if config['password'] and test_postgres_connection(config['host'], config['port']):
            print(f"🐘 PostgreSQL detected: {config['host']}:{config['port']}")
            return {
                'default': {
                    'ENGINE': 'django.db.backends.postgresql',
                    'NAME': config['name'],
                    'USER': config['user'],
                    'PASSWORD': config['password'],
                    'HOST': config['host'],
                    'PORT': config['port'],
                    'OPTIONS': {
                        'sslmode': 'disable',
                        'connect_timeout': 10,
                    },
                }
            }
    return None

def get_database_config():
    """Повна конфігурація бази даних"""
    
    # Для Codespace - перевіряємо PostgreSQL спочатку
    if RUNTIME_ENVIRONMENT == 'codespace':
        codespace_db = get_codespace_database_config()
        if codespace_db:
            return codespace_db
        
        # Якщо PostgreSQL недоступний у Codespace, використовуємо SQLite
        print("💾 Using SQLite in Codespace (PostgreSQL not available)")
        return {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': BASE_DIR / 'db.sqlite3',
            }
        }
    
    # Key Vault секрети
    db_password = get_secret('database-password') or get_secret('postgres-password')
    postgres_host = get_secret('postgres-host')
    postgres_database = get_secret('postgres-database', f'django_{ENVIRONMENT}')
    postgres_username = get_secret('postgres-username', 'dbadmin')
    postgres_port = get_secret('postgres-port', '5432')
    
    # Environment variables (legacy)
    db_password = db_password or os.environ.get('DB_PASSWORD')
    postgres_host = postgres_host or os.environ.get('DB_HOST', 'localhost')
    postgres_database = postgres_database or os.environ.get('DB_NAME', 'django-app_db')
    postgres_username = postgres_username or os.environ.get('DB_USER', 'djangoadmin')
    postgres_port = postgres_port or os.environ.get('DB_PORT', '5432')
    
    # DATABASE_URL має найвищий пріоритет
    database_url = get_secret('database-url') or os.environ.get('DATABASE_URL')
    if database_url:
        try:
            import dj_database_url
            config = dj_database_url.parse(database_url)
            if ENVIRONMENT in ['staging', 'prod', 'production']:
                config['OPTIONS'] = {'sslmode': 'require'}
            logger.info("Using database configuration from DATABASE_URL")
            return {'default': config}
        except ImportError:
            logger.warning("dj-database-url not installed")
    
    # PostgreSQL конфігурація з тестуванням підключення
    if db_password and postgres_host:
        if test_postgres_connection(postgres_host, postgres_port):
            logger.info("Using PostgreSQL configuration")
            ssl_mode = 'require' if ENVIRONMENT in ['staging', 'prod', 'production'] else 'prefer'
            
            return {
                'default': {
                    'ENGINE': 'django.db.backends.postgresql',
                    'NAME': postgres_database,
                    'USER': postgres_username,
                    'PASSWORD': db_password,
                    'HOST': postgres_host,
                    'PORT': postgres_port,
                    'OPTIONS': {
                        'sslmode': ssl_mode,
                        'connect_timeout': 60,
                    },
                    'CONN_MAX_AGE': 600,
                    'CONN_HEALTH_CHECKS': True,
                }
            }
        else:
            logger.warning(f"PostgreSQL not reachable at {postgres_host}:{postgres_port}, falling back to SQLite")
    
    # Fallback до SQLite
    if RUNTIME_ENVIRONMENT != 'codespace':
        logger.warning("No database credentials found, using SQLite")
    return {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

DATABASES = get_database_config()

# =============================================================================
# CACHE CONFIGURATION
# =============================================================================

def get_cache_config():
    """Конфігурація кешу"""
    if RUNTIME_ENVIRONMENT == 'codespace':
        return {
            'default': {
                'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
                'LOCATION': 'codespace-cache',
            }
        }
    
    redis_url = get_secret('redis-url')
    redis_password = get_secret('redis-password')
    
    if redis_url:
        redis_config = {
            "default": {
                "BACKEND": "django_redis.cache.RedisCache",
                "LOCATION": redis_url,
                "OPTIONS": {
                    "CLIENT_CLASS": "django_redis.client.DefaultClient",
                }
            }
        }
        
        if redis_password:
            redis_config["default"]["OPTIONS"]["PASSWORD"] = redis_password
        
        return redis_config
    
    return {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        }
    }

CACHES = get_cache_config()

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================

def get_email_config():
    """Конфігурація email"""
    if RUNTIME_ENVIRONMENT == 'codespace' or DEBUG:
        return {
            'EMAIL_BACKEND': 'django.core.mail.backends.console.EmailBackend',
        }
    
    return {
        'EMAIL_HOST': get_secret('email-host', 'localhost'),
        'EMAIL_PORT': int(get_secret('email-port', '25')),
        'EMAIL_HOST_USER': get_secret('email-host-user', ''),
        'EMAIL_HOST_PASSWORD': get_secret('email-host-password', ''),
        'EMAIL_USE_TLS': True,
        'DEFAULT_FROM_EMAIL': get_secret('default-from-email', 'noreply@example.com'),
    }

# Застосовуємо email конфігурацію
email_settings = get_email_config()
for key, value in email_settings.items():
    globals()[key] = value

# =============================================================================
# SECURITY SETTINGS
# =============================================================================

# Session configuration
SESSION_COOKIE_AGE = int(get_secret('session-cookie-age', '1209600'))  # 2 weeks
SESSION_COOKIE_NAME = get_secret('session-cookie-name', f'sessionid_{ENVIRONMENT}')

# Security settings для production
if ENVIRONMENT in ['staging', 'prod', 'production']:
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True

# =============================================================================
# PASSWORD VALIDATION
# =============================================================================

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# =============================================================================
# INTERNATIONALIZATION
# =============================================================================

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# =============================================================================
# STATIC & MEDIA FILES
# =============================================================================

# Статичні файли - перевіряємо існування папок
STATICFILES_DIRS = []
static_dirs_to_check = [
    BASE_DIR / 'static',
    BASE_DIR / 'project_portfolio' / 'static',
]

for static_dir in static_dirs_to_check:
    if static_dir.exists():
        STATICFILES_DIRS.append(static_dir)

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = 'media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Azure Storage configuration (якщо потрібно)
azure_storage_account = get_secret('azure-storage-account-name')
azure_storage_key = get_secret('azure-storage-account-key')

if azure_storage_account and azure_storage_key and ENVIRONMENT in ['staging', 'prod']:
    DEFAULT_FILE_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    STATICFILES_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    
    AZURE_ACCOUNT_NAME = azure_storage_account
    AZURE_ACCOUNT_KEY = azure_storage_key
    AZURE_CONTAINER = get_secret('azure-storage-container-media', 'media')
    AZURE_CUSTOM_DOMAIN = f'{azure_storage_account}.blob.core.windows.net'

# =============================================================================
# DEFAULT SETTINGS
# =============================================================================

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

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
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
        },
        __name__: {
            'handlers': ['console'],
            'level': 'DEBUG' if DEBUG else 'INFO',
        },
    },
}

# =============================================================================
# FINAL LOGGING - Спрощено для Codespace
# =============================================================================

# Виводимо інформацію про конфігурацію тільки один раз
print(f"✅ Django settings loaded for {'Codespace' if RUNTIME_ENVIRONMENT == 'codespace' else RUNTIME_ENVIRONMENT}")
print(f"🗄️ Database: {DATABASES['default']['ENGINE'].split('.')[-1].upper()}")
if DATABASES['default']['ENGINE'] != 'django.db.backends.sqlite3':
    print(f"🔗 DB Host: {DATABASES['default'].get('HOST', 'N/A')}")
print(f"🔧 Debug mode: {DEBUG}")
print(f"📧 Email: {'Console' if 'console' in EMAIL_BACKEND else 'SMTP'}")
print(f"📁 Templates: {len(TEMPLATES[0]['DIRS'])} directories configured")

# Тільки важливе логування для інших середовищ
if RUNTIME_ENVIRONMENT != 'codespace':
    logger.info(f"Database engine: {DATABASES['default']['ENGINE']}")
    logger.info(f"Database host: {DATABASES['default'].get('HOST', 'SQLite')}")
    logger.info(f"Runtime environment: {RUNTIME_ENVIRONMENT}")
    logger.info(f"Debug mode: {DEBUG}")
    logger.info(f"Allowed hosts: {len(ALLOWED_HOSTS)} hosts configured")
    logger.info(f"Cache backend: {CACHES['default']['BACKEND']}")
    
    if DATABASES['default']['ENGINE'] == 'django.db.backends.sqlite3':
        logger.info("💾 Using SQLite database")
    else:
        logger.info("🐘 Using PostgreSQL database")

# Validation критичних налаштувань
if not SECRET_KEY or SECRET_KEY == 'dev-secret-key-change-in-production':
    if ENVIRONMENT in ['prod', 'production']:
        raise ValueError("SECRET_KEY must be set for production!")
    elif RUNTIME_ENVIRONMENT != 'codespace':
        logger.warning("Using default SECRET_KEY in development")

# Фінальне повідомлення для Codespace
if RUNTIME_ENVIRONMENT == 'codespace':
    print("🚀 Codespace environment ready!")
    if 'django_browser_reload' in INSTALLED_APPS:
        print("📱 Browser auto-reload enabled")


```



Відмінне питання! Давайте детально розберемо, коли і як використовується PostgreSQL в цих налаштуваннях:

## 🐘 **Коли використовується PostgreSQL**

### **1. У GitHub Codespace:**
PostgreSQL використовується **ТІЛЬКИ якщо**:

```python
# Всі ці умови мають виконуватися:
1. ✅ Змінна середовища POSTGRES_PASSWORD встановлена
2. ✅ PostgreSQL сервер доступний на хості (localhost/db/postgres)
3. ✅ Тест підключення успішний (test_postgres_connection() повертає True)
```

**Конфігурації що перевіряються в Codespace:**
```python
codespace_configs = [
    # Конфігурація 1: Environment variables
    {
        'host': os.environ.get('POSTGRES_HOST', 'localhost'),
        'password': os.environ.get('POSTGRES_PASSWORD'),  # ОБОВ'ЯЗКОВО!
        'user': os.environ.get('POSTGRES_USER', 'postgres'),
        'port': os.environ.get('POSTGRES_PORT', '5432'),
    },
    # Конфігурація 2: Docker Compose
    {
        'host': 'db',
        'password': 'django_password',  # Hardcoded
        'user': 'django_user',
        'port': '5432',
    },
    # Конфігурація 3: Standard PostgreSQL
    {
        'host': 'postgres', 
        'password': 'password',  # Hardcoded
        'user': 'django',
        'port': '5432',
    }
]
```

### **2. В Azure App Service:**
PostgreSQL використовується якщо:
```python
# Пріоритет секретів:
1. ✅ DATABASE_URL з Key Vault (найвищий пріоритет)
2. ✅ Окремі postgres-* секрети з Key Vault
3. ✅ Environment variables (DB_PASSWORD, DB_HOST, etc.)
4. ❌ Fallback до SQLite якщо нічого не знайдено
```

### **3. В локальному середовищі:**
PostgreSQL використовується якщо:
```python
# Перевірка в порядку пріоритету:
1. DATABASE_URL environment variable
2. DB_PASSWORD + DB_HOST environment variables  
3. Azure Key Vault секрети (якщо Azure CLI налаштований)
4. Fallback до SQLite
```

## 🔍 **Практичні сценарії використання:**

### **Сценарій 1: Codespace з Docker PostgreSQL**
```bash
# Створіть .devcontainer/docker-compose.yml:
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: project_portfolio
      POSTGRES_USER: django_user  
      POSTGRES_PASSWORD: django_password
    ports:
      - "5432:5432"

# Результат: PostgreSQL буде використаний
```

### **Сценарій 2: Codespace з environment variables**
```bash
# У .devcontainer/devcontainer.json:
{
  "containerEnv": {
    "POSTGRES_HOST": "localhost",
    "POSTGRES_PASSWORD": "mypassword",
    "POSTGRES_USER": "django",
    "POSTGRES_DB": "django_app"
  }
}

# Потім запустіть PostgreSQL в Codespace:
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start

# Результат: PostgreSQL буде використаний
```

### **Сценарій 3: Azure App Service з Key Vault**
```bash
# Key Vault секрети:
database-url = "postgresql://user:pass@host:5432/db?sslmode=require"
# АБО
postgres-host = "myapp-postgres.postgres.database.azure.com"
postgres-password = "securepassword"
postgres-username = "dbadmin"

# Результат: PostgreSQL буде використаний
```

### **Сценарій 4: Локальна розробка**
```bash
# Environment variables:
export DB_HOST="localhost"
export DB_PASSWORD="localpassword"  
export DB_USER="postgres"
export DB_NAME="django_local"

# Запустіть локальний PostgreSQL
brew install postgresql  # macOS
brew services start postgresql

# Результат: PostgreSQL буде використаний
```

## ❌ **Коли PostgreSQL НЕ використовується:**

### **В Codespace використовується SQLite якщо:**
- ❌ `POSTGRES_PASSWORD` не встановлена
- ❌ PostgreSQL сервер не запущений або недоступний
- ❌ Тест підключення не вдається (timeout 2 секунди)

### **Приклад поточної ситуації (ваш Codespace):**
```bash
💾 Using SQLite in Codespace (PostgreSQL not available)

# Це означає що:
- os.environ.get('POSTGRES_PASSWORD') is None
- test_postgres_connection('localhost', '5432') == False  
- test_postgres_connection('db', '5432') == False
- test_postgres_connection('postgres', '5432') == False
```

## 🚀 **Як увімкнути PostgreSQL в Codespace:**

### **Варіант 1: Docker Compose (рекомендовано)**
```bash
# Створіть .devcontainer/docker-compose.yml
mkdir -p .devcontainer

cat > .devcontainer/docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    volumes:
      - ..:/workspaces:cached
    command: sleep infinity
    
  db:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_DB: project_portfolio
      POSTGRES_USER: django_user
      POSTGRES_PASSWORD: django_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

# Створіть .devcontainer/devcontainer.json
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Django PostgreSQL",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces",
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python"]
    }
  }
}
EOF

# Перезапустіть Codespace
```

### **Варіант 2: Environment Variables**
```bash
# У терміналі Codespace:
export POSTGRES_HOST="localhost"
export POSTGRES_PASSWORD="mypassword"
export POSTGRES_USER="django"
export POSTGRES_DB="django_app"

# Встановіть і запустіть PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo service postgresql start

# Створіть базу та користувача
sudo -u postgres createuser django
sudo -u postgres createdb django_app
sudo -u postgres psql -c "ALTER USER django PASSWORD 'mypassword';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE django_app TO django;"

# Перезапустіть Django
python manage.py runserver 0.0.0.0:8000
```

## 🔍 **Перевірка поточної конфігурації:**

```bash
# Перевірте які змінні встановлені:
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"  
echo "POSTGRES_USER: $POSTGRES_USER"

# Перевірте чи PostgreSQL запущений:
sudo service postgresql status

# Тест підключення:
python -c "
import socket
try:
    sock = socket.create_connection(('localhost', 5432), 2)
    print('✅ PostgreSQL available')
    sock.close()
except:
    print('❌ PostgreSQL not available')
"
```

**Зараз у вашому Codespace PostgreSQL не використовується, тому що немає налаштованого PostgreSQL сервера або environment variables.** 

Хочете налаштувати PostgreSQL? 🐘


Відмінно! Давайте налаштуємо PostgreSQL у вашому GitHub Codespace. Я покажу найпростіший спосіб:

## 🐘 **Спосіб 1: Швидке налаштування PostgreSQL**

### **1. Встановіть PostgreSQL в Codespace:**
```bash
# Оновіть пакети
sudo apt-get update

# Встановіть PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib

# Запустіть PostgreSQL сервіс
sudo service postgresql start

# Перевірте статус
sudo service postgresql status
```

### **2. Створіть базу даних та користувача:**
```bash
# Перейдіть до postgres користувача та створіть DB
sudo -u postgres createuser --interactive --pwprompt django

# Введіть пароль: django_password
# Shall the new role be a superuser? (y/n) y

# Створіть базу даних
sudo -u postgres createdb -O django project_portfolio

# Або через psql:
sudo -u postgres psql << EOF
CREATE USER django WITH PASSWORD 'django_password';
CREATE DATABASE project_portfolio OWNER django;
GRANT ALL PRIVILEGES ON DATABASE project_portfolio TO django;
\q
EOF
```

### **3. Встановіть змінні середовища:**
```bash
# Додайте у ваш термінал (або .bashrc):
export POSTGRES_HOST="localhost"
export POSTGRES_PASSWORD="django_password"
export POSTGRES_USER="django"
export POSTGRES_DB="project_portfolio"
export POSTGRES_PORT="5432"

# Перевірте змінні:
echo "Host: $POSTGRES_HOST"
echo "Password: $POSTGRES_PASSWORD"
echo "User: $POSTGRES_USER"
echo "DB: $POSTGRES_DB"
```

### **4. Встановіть PostgreSQL драйвер для Python:**
```bash
# Встановіть psycopg2
pip install psycopg2-binary

# Або додайте в requirements.txt:
echo "psycopg2-binary>=2.9.0" >> requirements.txt
pip install -r requirements.txt
```

### **5. Перезапустіть Django:**
```bash
# Зупиніть поточний сервер (Ctrl+C)
# Потім запустіть знову:
python manage.py runserver 0.0.0.0:8000
```

## 🚀 **Спосіб 2: Автоматизований скрипт**

Створіть скрипт для швидкого налаштування:

```bash
# Створіть скрипт
cat > setup-postgres.sh << 'EOF'
#!/bin/bash
set -e

echo "🐘 Налаштування PostgreSQL для Django..."

# Встановлення PostgreSQL
echo "📦 Встановлення PostgreSQL..."
sudo apt-get update -q
sudo apt-get install -y postgresql postgresql-contrib

# Запуск сервісу
echo "🚀 Запуск PostgreSQL..."
sudo service postgresql start

# Створення користувача та бази даних
echo "👤 Створення користувача django..."
sudo -u postgres psql << PSQL
CREATE USER django WITH PASSWORD 'django_password' SUPERUSER;
CREATE DATABASE project_portfolio OWNER django;
GRANT ALL PRIVILEGES ON DATABASE project_portfolio TO django;
\q
PSQL

# Встановлення Python драйвера
echo "🐍 Встановлення psycopg2..."
pip install psycopg2-binary

# Встановлення змінних середовища
echo "⚙️ Налаштування змінних середовища..."
cat >> ~/.bashrc << ENV
export POSTGRES_HOST="localhost"
export POSTGRES_PASSWORD="django_password"  
export POSTGRES_USER="django"
export POSTGRES_DB="project_portfolio"
export POSTGRES_PORT="5432"
ENV

# Експорт для поточної сесії
export POSTGRES_HOST="localhost"
export POSTGRES_PASSWORD="django_password"
export POSTGRES_USER="django" 
export POSTGRES_DB="project_portfolio"
export POSTGRES_PORT="5432"

echo "✅ PostgreSQL налаштовано!"
echo "🔄 Перезапустіть Django сервер:"
echo "   python manage.py runserver 0.0.0.0:8000"

# Тест підключення
echo "🧪 Тестування підключення..."
python -c "
import psycopg2
try:
    conn = psycopg2.connect(
        host='localhost',
        database='project_portfolio', 
        user='django',
        password='django_password'
    )
    print('✅ PostgreSQL підключення успішне!')
    conn.close()
except Exception as e:
    print(f'❌ Помилка підключення: {e}')
"
EOF

# Зробіть скрипт виконуваним
chmod +x setup-postgres.sh

# Запустіть скрипт
./setup-postgres.sh
```

## 🔄 **Спосіб 3: Docker Compose (для майбутніх Codespace)**

Створіть конфігурацію для автоматичного PostgreSQL:

```bash
# Створіть папку для devcontainer
mkdir -p .devcontainer

# Створіть docker-compose.yml
cat > .devcontainer/docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    image: mcr.microsoft.com/devcontainers/python:3.12
    volumes:
      - ../..:/workspaces:cached
    command: sleep infinity
    depends_on:
      - db
    environment:
      POSTGRES_HOST: db
      POSTGRES_PASSWORD: django_password
      POSTGRES_USER: django
      POSTGRES_DB: project_portfolio
      POSTGRES_PORT: 5432

  db:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_DB: project_portfolio
      POSTGRES_USER: django
      POSTGRES_PASSWORD: django_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
EOF

# Створіть devcontainer.json
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Django with PostgreSQL",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.black-formatter"
      ]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt && python manage.py migrate",
  "forwardPorts": [8000, 5432]
}
EOF

echo "📁 Devcontainer створено! Перезапустіть Codespace для використання PostgreSQL."
```

## ✅ **Перевірка успішного налаштування:**

```bash
# 1. Перевірте що PostgreSQL запущений
sudo service postgresql status

# 2. Перевірте підключення
python -c "
import socket
try:
    socket.create_connection(('localhost', 5432), 2)
    print('✅ PostgreSQL доступний')
except:
    print('❌ PostgreSQL недоступний')
"

# 3. Перевірте змінні середовища
env | grep POSTGRES

# 4. Тест Django підключення
python manage.py check --database default

# 5. Запустіть міграції
python manage.py migrate

# 6. Перезапустіть сервер
python manage.py runserver 0.0.0.0:8000
```

## 🎯 **Результат:**

Після налаштування ви побачите:
```bash
🐘 PostgreSQL detected: localhost:5432
✅ Django settings loaded for Codespace
🗄️ Database: POSTGRESQL
🔗 DB Host: localhost
🔧 Debug mode: True
📧 Email: Console
📁 Templates: 2 directories configured
🚀 Codespace environment ready!
```

Який спосіб ви хочете використати? Рекомендую **Спосіб 2 (автоматизований скрипт)** для швидкого результату! 🚀
