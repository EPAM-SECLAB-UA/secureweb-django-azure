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


```
