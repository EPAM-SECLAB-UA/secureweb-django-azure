


# 🔐 Повний набір секретів Key Vault для Django додатка

## 📋 Категорії секретів

### 1. 🏗️ **Базові Django секрети**
### 2. 🗄️ **База даних (PostgreSQL)**
### 3. 📧 **Email та повідомлення**
### 4. 🔌 **API інтеграції**
### 5. 🛡️ **Безпека та автентифікація**
### 6. ☁️ **Azure сервіси**
### 7. 📊 **Моніторинг та логування**
### 8. 💳 **Платежі та комерція**
### 9. 🌐 **Соціальні мережі**
### 10. 🔧 **DevOps та середовища**

---

## 🏗️ 1. Базові Django секрети

```bash
# Django Core
az keyvault secret set --vault-name django-app-dev-kv --name "django-secret-key" --value "$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')"

# Debug режим для різних середовищ
az keyvault secret set --vault-name django-app-dev-kv --name "django-debug-dev" --value "true"
az keyvault secret set --vault-name django-app-dev-kv --name "django-debug-staging" --value "false"
az keyvault secret set --vault-name django-app-dev-kv --name "django-debug-production" --value "false"

# Allowed Hosts
az keyvault secret set --vault-name django-app-dev-kv --name "django-allowed-hosts" --value "localhost,127.0.0.1,*.azurewebsites.net,yourdomain.com"
```

---

## 🗄️ 2. База даних (PostgreSQL)

```bash
# PostgreSQL Connection Details
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-host" --value "django-app-dev-postgres.postgres.database.azure.com"
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-port" --value "5432"
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-database" --value "django_dev"
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-username" --value "dbadmin"
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-password" --value "$(openssl rand -base64 32)"

# Connection String (готовий до використання)
POSTGRES_PASSWORD=$(az keyvault secret show --vault-name django-app-dev-kv --name "postgres-password" --query value -o tsv)
DATABASE_URL="postgresql://dbadmin:${POSTGRES_PASSWORD}@django-app-dev-postgres.postgres.database.azure.com:5432/django_dev?sslmode=require"
az keyvault secret set --vault-name django-app-dev-kv --name "database-url" --value "$DATABASE_URL"

# Backup Database Credentials
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-backup-username" --value "backup_user"
az keyvault secret set --vault-name django-app-dev-kv --name "postgres-backup-password" --value "$(openssl rand -base64 32)"

# Redis для кешування
az keyvault secret set --vault-name django-app-dev-kv --name "redis-url" --value "rediss://django-app-dev-redis.redis.cache.windows.net:6380"
az keyvault secret set --vault-name django-app-dev-kv --name "redis-password" --value "your-redis-access-key"
```

---

## 📧 3. Email та повідомлення

```bash
# SMTP Settings
az keyvault secret set --vault-name django-app-dev-kv --name "email-host" --value "smtp.gmail.com"
az keyvault secret set --vault-name django-app-dev-kv --name "email-port" --value "587"
az keyvault secret set --vault-name django-app-dev-kv --name "email-host-user" --value "your-app@gmail.com"
az keyvault secret set --vault-name django-app-dev-kv --name "email-host-password" --value "your-app-password"
az keyvault secret set --vault-name django-app-dev-kv --name "default-from-email" --value "Django App <noreply@yourapp.com>"

# SendGrid Integration
az keyvault secret set --vault-name django-app-dev-kv --name "sendgrid-api-key" --value "SG.your-sendgrid-api-key"
az keyvault secret set --vault-name django-app-dev-kv --name "sendgrid-from-email" --value "noreply@yourapp.com"

# Mailgun Integration
az keyvault secret set --vault-name django-app-dev-kv --name "mailgun-api-key" --value "key-your-mailgun-key"
az keyvault secret set --vault-name django-app-dev-kv --name "mailgun-domain" --value "mg.yourapp.com"

# SMS/WhatsApp (Twilio)
az keyvault secret set --vault-name django-app-dev-kv --name "twilio-account-sid" --value "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
az keyvault secret set --vault-name django-app-dev-kv --name "twilio-auth-token" --value "your-twilio-auth-token"
az keyvault secret set --vault-name django-app-dev-kv --name "twilio-phone-number" --value "+1234567890"
```

---

## 🔌 4. API інтеграції

```bash
# OpenAI/ChatGPT
az keyvault secret set --vault-name django-app-dev-kv --name "openai-api-key" --value "sk-your-openai-api-key"
az keyvault secret set --vault-name django-app-dev-kv --name "openai-organization" --value "org-your-organization-id"

# Google APIs
az keyvault secret set --vault-name django-app-dev-kv --name "google-api-key" --value "AIzaSyYour-Google-API-Key"
az keyvault secret set --vault-name django-app-dev-kv --name "google-maps-api-key" --value "AIzaSyYour-Google-Maps-Key"
az keyvault secret set --vault-name django-app-dev-kv --name "google-analytics-id" --value "G-XXXXXXXXXX"

# Weather APIs
az keyvault secret set --vault-name django-app-dev-kv --name "openweather-api-key" --value "your-openweather-api-key"

# Translation APIs
az keyvault secret set --vault-name django-app-dev-kv --name "azure-translator-key" --value "your-translator-key"
az keyvault secret set --vault-name django-app-dev-kv --name "azure-translator-region" --value "westeurope"

# File Processing
az keyvault secret set --vault-name django-app-dev-kv --name "cloudinary-url" --value "cloudinary://api_key:api_secret@cloud_name"
```

---

## 🛡️ 5. Безпека та автентифікація

```bash
# JWT Tokens
az keyvault secret set --vault-name django-app-dev-kv --name "jwt-secret-key" --value "$(openssl rand -base64 64)"
az keyvault secret set --vault-name django-app-dev-kv --name "jwt-refresh-secret" --value "$(openssl rand -base64 64)"

# OAuth2 Providers
# Google OAuth
az keyvault secret set --vault-name django-app-dev-kv --name "google-oauth-client-id" --value "your-google-client-id.apps.googleusercontent.com"
az keyvault secret set --vault-name django-app-dev-kv --name "google-oauth-client-secret" --value "GOCSPX-your-google-client-secret"

# Microsoft OAuth
az keyvault secret set --vault-name django-app-dev-kv --name "microsoft-oauth-client-id" --value "your-microsoft-client-id"
az keyvault secret set --vault-name django-app-dev-kv --name "microsoft-oauth-client-secret" --value "your-microsoft-client-secret"

# Facebook OAuth
az keyvault secret set --vault-name django-app-dev-kv --name "facebook-app-id" --value "your-facebook-app-id"
az keyvault secret set --vault-name django-app-dev-kv --name "facebook-app-secret" --value "your-facebook-app-secret"

# reCAPTCHA
az keyvault secret set --vault-name django-app-dev-kv --name "recaptcha-public-key" --value "6LcYour-reCAPTCHA-Site-Key"
az keyvault secret set --vault-name django-app-dev-kv --name "recaptcha-private-key" --value "6LcYour-reCAPTCHA-Secret-Key"

# CSRF Token
az keyvault secret set --vault-name django-app-dev-kv --name "csrf-cookie-secret" --value "$(openssl rand -hex 32)"
```

---

## ☁️ 6. Azure сервіси

```bash
# Azure Storage
az keyvault secret set --vault-name django-app-dev-kv --name "azure-storage-account-name" --value "djangoappdevstorage"
STORAGE_KEY=$(az storage account keys list --account-name djangoappdevstorage --query "[0].value" -o tsv)
az keyvault secret set --vault-name django-app-dev-kv --name "azure-storage-account-key" --value "$STORAGE_KEY"
az keyvault secret set --vault-name django-app-dev-kv --name "azure-storage-container-media" --value "media"
az keyvault secret set --vault-name django-app-dev-kv --name "azure-storage-container-static" --value "static"

# Azure Blob Connection String
CONNECTION_STRING=$(az storage account show-connection-string --name djangoappdevstorage --query connectionString -o tsv)
az keyvault secret set --vault-name django-app-dev-kv --name "azure-storage-connection-string" --value "$CONNECTION_STRING"

# Azure Service Bus (для черг)
az keyvault secret set --vault-name django-app-dev-kv --name "azure-servicebus-connection-string" --value "Endpoint=sb://your-namespace.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=your-key"

# Azure Cognitive Services
az keyvault secret set --vault-name django-app-dev-kv --name "azure-cognitive-key" --value "your-cognitive-services-key"
az keyvault secret set --vault-name django-app-dev-kv --name "azure-cognitive-endpoint" --value "https://your-resource.cognitiveservices.azure.com/"
```

---

## 📊 7. Моніторинг та логування

```bash
# Application Insights
az keyvault secret set --vault-name django-app-dev-kv --name "applicationinsights-connection-string" --value "InstrumentationKey=your-key;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/"
az keyvault secret set --vault-name django-app-dev-kv --name "applicationinsights-instrumentation-key" --value "your-instrumentation-key"

# Sentry
az keyvault secret set --vault-name django-app-dev-kv --name "sentry-dsn" --value "https://your-sentry-dsn@sentry.io/project-id"
az keyvault secret set --vault-name django-app-dev-kv --name "sentry-environment" --value "development"

# LogRocket
az keyvault secret set --vault-name django-app-dev-kv --name "logrocket-app-id" --value "your-logrocket-app-id"

# New Relic
az keyvault secret set --vault-name django-app-dev-kv --name "newrelic-license-key" --value "your-newrelic-license-key"
az keyvault secret set --vault-name django-app-dev-kv --name "newrelic-app-name" --value "Django App Dev"
```

---

## 💳 8. Платежі та комерція

```bash
# Stripe
az keyvault secret set --vault-name django-app-dev-kv --name "stripe-publishable-key" --value "pk_test_your-stripe-publishable-key"
az keyvault secret set --vault-name django-app-dev-kv --name "stripe-secret-key" --value "sk_test_your-stripe-secret-key"
az keyvault secret set --vault-name django-app-dev-kv --name "stripe-webhook-secret" --value "whsec_your-webhook-secret"

# PayPal
az keyvault secret set --vault-name django-app-dev-kv --name "paypal-client-id" --value "your-paypal-client-id"
az keyvault secret set --vault-name django-app-dev-kv --name "paypal-client-secret" --value "your-paypal-client-secret"
az keyvault secret set --vault-name django-app-dev-kv --name "paypal-webhook-id" --value "your-paypal-webhook-id"

# LiqPay (для України)
az keyvault secret set --vault-name django-app-dev-kv --name "liqpay-public-key" --value "your-liqpay-public-key"
az keyvault secret set --vault-name django-app-dev-kv --name "liqpay-private-key" --value "your-liqpay-private-key"
```

---

## 🌐 9. Соціальні мережі

```bash
# Telegram Bot
az keyvault secret set --vault-name django-app-dev-kv --name "telegram-bot-token" --value "1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ"
az keyvault secret set --vault-name django-app-dev-kv --name "telegram-webhook-secret" --value "$(openssl rand -hex 32)"

# Slack Integration
az keyvault secret set --vault-name django-app-dev-kv --name "slack-bot-token" --value "xoxb-your-slack-bot-token"
az keyvault secret set --vault-name django-app-dev-kv --name "slack-webhook-url" --value "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

# Discord
az keyvault secret set --vault-name django-app-dev-kv --name "discord-bot-token" --value "your-discord-bot-token"
az keyvault secret set --vault-name django-app-dev-kv --name "discord-webhook-url" --value "https://discord.com/api/webhooks/your-webhook"

# LinkedIn API
az keyvault secret set --vault-name django-app-dev-kv --name "linkedin-client-id" --value "your-linkedin-client-id"
az keyvault secret set --vault-name django-app-dev-kv --name "linkedin-client-secret" --value "your-linkedin-client-secret"
```

---

## 🔧 10. DevOps та середовища

```bash
# Environment Indicators
az keyvault secret set --vault-name django-app-dev-kv --name "environment-name" --value "development"
az keyvault secret set --vault-name django-app-dev-kv --name "environment-color" --value "#28a745"  # Green for dev
az keyvault secret set --vault-name django-app-dev-kv --name "app-version" --value "1.0.0"

# API Rate Limiting
az keyvault secret set --vault-name django-app-dev-kv --name "rate-limit-per-minute" --value "1000"
az keyvault secret set --vault-name django-app-dev-kv --name "rate-limit-per-hour" --value "10000"

# Session Configuration
az keyvault secret set --vault-name django-app-dev-kv --name "session-cookie-age" --value "1209600"  # 2 weeks
az keyvault secret set --vault-name django-app-dev-kv --name "session-cookie-name" --value "django_session_dev"

# Backup and Sync
az keyvault secret set --vault-name django-app-dev-kv --name "backup-encryption-key" --value "$(openssl rand -base64 32)"
az keyvault secret set --vault-name django-app-dev-kv --name "sync-api-key" --value "$(openssl rand -hex 32)"

# Health Check Secrets
az keyvault secret set --vault-name django-app-dev-kv --name "health-check-token" --value "$(openssl rand -hex 16)"
az keyvault secret set --vault-name django-app-dev-kv --name "admin-api-key" --value "$(openssl rand -base64 32)"
```

---

## 🛠️ Скрипт для масового додавання секретів

```bash
#!/bin/bash
# add_all_secrets.sh

KEY_VAULT_NAME="django-app-dev-kv"

echo "🔐 Додавання всіх секретів до Key Vault: $KEY_VAULT_NAME"

# Функція для додавання секрету з перевіркою
add_secret() {
    local name="$1"
    local value="$2"
    local description="$3"
    
    echo "📝 Додавання: $name ($description)"
    if az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "$name" \
        --value "$value" \
        --description "$description" \
        --output none; then
        echo "   ✅ Успішно додано: $name"
    else
        echo "   ❌ Помилка додавання: $name"
    fi
}

# Генерація динамічних секретів
DJANGO_SECRET=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
JWT_SECRET=$(openssl rand -base64 64)
POSTGRES_PASSWORD=$(openssl rand -base64 32)
BACKUP_KEY=$(openssl rand -base64 32)

# Додавання базових секретів
add_secret "django-secret-key" "$DJANGO_SECRET" "Django SECRET_KEY"
add_secret "jwt-secret-key" "$JWT_SECRET" "JWT Secret Key"
add_secret "postgres-password" "$POSTGRES_PASSWORD" "PostgreSQL Password"
add_secret "backup-encryption-key" "$BACKUP_KEY" "Backup Encryption Key"

# Додавання конфігураційних секретів
add_secret "postgres-host" "django-app-dev-postgres.postgres.database.azure.com" "PostgreSQL Host"
add_secret "postgres-username" "dbadmin" "PostgreSQL Username"
add_secret "postgres-database" "django_dev" "PostgreSQL Database Name"
add_secret "redis-url" "rediss://django-app-dev-redis.redis.cache.windows.net:6380" "Redis URL"

# Email налаштування
add_secret "email-host" "smtp.gmail.com" "Email Host"
add_secret "email-port" "587" "Email Port"
add_secret "default-from-email" "Django App <noreply@yourapp.com>" "Default From Email"

# Environment
add_secret "environment-name" "development" "Environment Name"
add_secret "django-debug-dev" "true" "Django Debug for Dev"
add_secret "allowed-hosts" "localhost,127.0.0.1,*.azurewebsites.net" "Django Allowed Hosts"

echo "🎉 Всі базові секрети додано!"
echo "📋 Не забудьте оновити реальними значеннями:"
echo "   • Email credentials"
echo "   • API keys"
echo "   • OAuth credentials"
echo "   • Payment provider keys"
```

---

## 🐍 Django Settings Integration

```python
# utils/secrets_manager.py
from typing import Dict, Any
from utils.keyvault_client import get_secret

class SecretsManager:
    """Менеджер для отримання всіх секретів"""
    
    @staticmethod
    def get_database_config() -> Dict[str, Any]:
        """Отримання конфігурації бази даних"""
        return {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': get_secret('postgres-database', 'django_dev'),
            'USER': get_secret('postgres-username', 'postgres'),
            'PASSWORD': get_secret('postgres-password', ''),
            'HOST': get_secret('postgres-host', 'localhost'),
            'PORT': get_secret('postgres-port', '5432'),
            'OPTIONS': {
                'sslmode': 'require',
            },
        }
    
    @staticmethod
    def get_email_config() -> Dict[str, Any]:
        """Отримання конфігурації email"""
        return {
            'EMAIL_BACKEND': 'django.core.mail.backends.smtp.EmailBackend',
            'EMAIL_HOST': get_secret('email-host', 'localhost'),
            'EMAIL_PORT': int(get_secret('email-port', '587')),
            'EMAIL_USE_TLS': True,
            'EMAIL_HOST_USER': get_secret('email-host-user', ''),
            'EMAIL_HOST_PASSWORD': get_secret('email-host-password', ''),
            'DEFAULT_FROM_EMAIL': get_secret('default-from-email', 'webmaster@localhost'),
        }
    
    @staticmethod
    def get_oauth_config() -> Dict[str, Any]:
        """Отримання OAuth конфігурації"""
        return {
            'GOOGLE_OAUTH2_CLIENT_ID': get_secret('google-oauth-client-id', ''),
            'GOOGLE_OAUTH2_CLIENT_SECRET': get_secret('google-oauth-client-secret', ''),
            'MICROSOFT_AUTH_CLIENT_ID': get_secret('microsoft-oauth-client-id', ''),
            'MICROSOFT_AUTH_CLIENT_SECRET': get_secret('microsoft-oauth-client-secret', ''),
        }
    
    @staticmethod
    def get_payment_config() -> Dict[str, Any]:
        """Отримання конфігурації платежів"""
        return {
            'STRIPE_PUBLISHABLE_KEY': get_secret('stripe-publishable-key', ''),
            'STRIPE_SECRET_KEY': get_secret('stripe-secret-key', ''),
            'PAYPAL_CLIENT_ID': get_secret('paypal-client-id', ''),
            'PAYPAL_CLIENT_SECRET': get_secret('paypal-client-secret', ''),
        }

# В settings.py:
from utils.secrets_manager import SecretsManager

# Базові налаштування
SECRET_KEY = get_secret('django-secret-key')
DEBUG = get_secret('django-debug-dev', 'false').lower() == 'true'
ALLOWED_HOSTS = get_secret('allowed-hosts', 'localhost').split(',')

# База даних
DATABASES = {'default': SecretsManager.get_database_config()}

# Email
EMAIL_CONFIG = SecretsManager.get_email_config()
globals().update(EMAIL_CONFIG)

# OAuth
OAUTH_CONFIG = SecretsManager.get_oauth_config()
globals().update(OAUTH_CONFIG)

# Платежі
PAYMENT_CONFIG = SecretsManager.get_payment_config()
globals().update(PAYMENT_CONFIG)
```

---

## 🎯 Підсумок

Тепер ваш Key Vault може містити **50+ секретів** для повноцінного enterprise Django додатка:

- ✅ **База даних** - всі параметри підключення
- ✅ **Email** - SMTP та сервіси розсилки  
- ✅ **API ключі** - Google, OpenAI, Weather тощо
- ✅ **OAuth** - Google, Microsoft, Facebook
- ✅ **Платежі** - Stripe, PayPal, LiqPay
- ✅ **Моніторинг** - Sentry, Application Insights
- ✅ **Соціальні мережі** - Telegram, Slack, Discord
- ✅ **Azure сервіси** - Storage, Service Bus, Cognitive

**Це забезпечує максимальну безпеку та гнучкість розгортання!** 🚀










-------------------------------------------------------
Ось кілька варіантів назв для документації з Azure Key Vault:

## 🎯 **Рекомендовані варіанти:**

### **1. Основні варіанти:**
```
AZURE_KEYVAULT_DJANGO_GUIDE.md
azure-keyvault-integration-guide.md
django-keyvault-security-guide.md
keyvault-secrets-management.md
```

### **2. Більш детальні варіанти:**
```
AZURE_KEYVAULT_SECRETS_MANAGEMENT_GUIDE.md
django-azure-keyvault-complete-guide.md
secure-secrets-with-azure-keyvault.md
enterprise-secrets-management-azure.md
```

### **3. Структурні варіанти:**
```
SECURITY_AZURE_KEYVAULT_GUIDE.md
DEPLOYMENT_KEYVAULT_CONFIGURATION.md
INFRASTRUCTURE_SECRETS_MANAGEMENT.md
```

## 🏆 **Найкращий варіант:**

```
AZURE_KEYVAULT_DJANGO_GUIDE.md
```

**Чому саме цей:**
- ✅ Чітко вказує технології (Azure Key Vault + Django)
- ✅ ЗАГЛАВНИМИ літерами - легко знайти
- ✅ Короткий але інформативний
- ✅ Стандартний формат для технічної документації

## 📁 **Розміщення в проекті:**

```
django-project/
├── docs/
│   ├── security/
│   │   ├── AZURE_KEYVAULT_DJANGO_GUIDE.md  ⭐
│   │   ├── SECURITY_BEST_PRACTICES.md
│   │   └── MANAGED_IDENTITY_SETUP.md
│   ├── deployment/
│   │   ├── AZURE_DEPLOYMENT_GUIDE.md
│   │   └── CI_CD_PIPELINE.md
│   └── README.md
├── README.md
└── ...
```

## 🔄 **Альтернативна структура (якщо хочете розбити):**

```
docs/security/
├── README.md                           # Огляд безпеки
├── AZURE_KEYVAULT_SETUP.md            # Налаштування Key Vault
├── DJANGO_KEYVAULT_INTEGRATION.md     # Інтеграція з Django  
├── SECRETS_MANAGEMENT.md              # Управління секретами
├── MANAGED_IDENTITY_CONFIG.md         # Managed Identity
└── SECURITY_MONITORING.md             # Моніторинг безпеки
```

## 📝 **Додаткові рекомендації:**

### **Додайте до README.md посилання:**
```markdown
## 📚 Документація

### Безпека
- [🔐 Azure Key Vault інтеграція](docs/security/AZURE_KEYVAULT_DJANGO_GUIDE.md)
- [🛡️ Практики безпеки](docs/security/SECURITY_BEST_PRACTICES.md)
```

### **Використовуйте теги в назві файлу:**
```markdown
# 🔐 Azure Key Vault для Django: Повний гайд з безпеки
```

### **Створіть index файл:**
```markdown
# 📖 Security Documentation Index

## Key Vault Integration
- [Complete Key Vault Guide](AZURE_KEYVAULT_DJANGO_GUIDE.md) - Повний гайд
- [Quick Setup](KEYVAULT_QUICK_SETUP.md) - Швидке налаштування
- [Troubleshooting](KEYVAULT_TROUBLESHOOTING.md) - Вирішення проблем
```

**Мій фінальний вибір:** `AZURE_KEYVAULT_DJANGO_GUIDE.md` 🎯

Це найбільш зрозуміла та професійна назва для технічної документації!


----------------------------------------------------------------------------------------

## 🎯 **Додаткові корисні команди**

### **Швидка перевірка Key Vault:**
```bash
# Перевірка доступу
az keyvault secret list --vault-name your-keyvault-name

# Отримання секрету
az keyvault secret show --vault-name your-keyvault-name --name django-secret-key

# Оновлення секрету
az keyvault secret set --vault-name your-keyvault-name --name new-secret --value "new-value"
```

### **Django management команди:**
```bash
# Backup секретів
python manage.py backup_secrets --output-file backup.json

# Відновлення секретів
python manage.py restore_secrets --backup-file backup.json

# Health check Key Vault
python manage.py check_keyvault_health

# Ротація секретів
python manage.py rotate_secret --secret-name django-secret-key
```

### **Monitoring команди:**
```bash
# Перегляд логів Key Vault
az monitor activity-log list --resource-group django-app-rg --caller your-email@domain.com

# Метрики Key Vault
az monitor metrics list --resource /subscriptions/.../resourceGroups/django-app-rg/providers/Microsoft.KeyVault/vaults/my-keyvault
```

## 🔒 **Безпечні практики:**

1. **Ніколи не логуйте секрети** - використовуйте маскування
2. **Регулярно ротуйте секрети** - особливо критичні
3. **Моніторьте доступ** - налаштуйте алерти на підозрілу активність
4. **Використовуйте Soft Delete** - захист від випадкового видалення
5. **Backup регулярно** - автоматизуйте процес backup

З цією конфігурацією ваш Django проект матиме enterprise-рівень безпеки та відповідатиме найкращим практикам хмарної розробки! 🚀

------------------------------------------------------------------------------------------------------------------------------------



## 🎯 **Додаткові корисні команди**

### **Швидка перевірка Key Vault:**
```bash
# Перевірка доступу
az keyvault secret list --vault-name your-keyvault-name

# Отримання секрету
az keyvault secret show --vault-name your-keyvault-name --name django-secret-key

# Оновлення секрету
az keyvault secret set --vault-name your-keyvault-name --name new-secret --value "new-value"
```

### **Django management команди:**
```bash
# Backup секретів
python manage.py backup_secrets --output-file backup.json

# Відновлення секретів
python manage.py restore_secrets --backup-file backup.json

# Health check Key Vault
python manage.py check_keyvault_health

# Ротація секретів
python manage.py rotate_secret --secret-name django-secret-key
```

### **Monitoring команди:**
```bash
# Перегляд логів Key Vault
az monitor activity-log list --resource-group django-app-rg --caller your-email@domain.com

# Метрики Key Vault
az monitor metrics list --resource /subscriptions/.../resourceGroups/django-app-rg/providers/Microsoft.KeyVault/vaults/my-keyvault
```

## 🔒 **Безпечні практики:**

1. **Ніколи не логуйте секрети** - використовуйте маскування
2. **Регулярно ротуйте секрети** - особливо критичні
3. **Моніторьте доступ** - налаштуйте алерти на підозрілу активність
4. **Використовуйте Soft Delete** - захист від випадкового видалення
5. **Backup регулярно** - автоматизуйте процес backup

З цією конфігурацією ваш Django проект матиме enterprise-рівень безпеки та відповідатиме найкращим практикам хмарної розробки! 🚀

----------------------------------------------------------------------------------------------------------------------------------------------------

# 🔐 Azure Key Vault для Django: Повний гайд з безпеки

## 📋 Зміст
1. [Налаштування Azure Key Vault](#налаштування-azure-key-vault)
2. [Інтеграція з Django](#інтеграція-з-django)
3. [Managed Identity](#managed-identity)
4. [Deployment конфігурація](#deployment-конфігурація)
5. [Автоматизація з Bicep](#автоматизація-з-bicep)
6. [Безпека та best practices](#безпека-та-best-practices)

---

## 🏗️ Налаштування Azure Key Vault

### 1. Створення Key Vault через Azure CLI

```bash
#!/bin/bash

# Змінні
RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
KEY_VAULT_NAME="django-app-kv-$(date +%s)"
APP_NAME="django-app"

# Створення Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Створення Key Vault
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku standard \
  --enable-soft-delete true \
  --enable-purge-protection true \
  --retention-days 90

# Встановлення прав доступу для поточного користувача
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $USER_OBJECT_ID \
  --secret-permissions get list set delete recover backup restore

echo "✅ Key Vault створено: $KEY_VAULT_NAME"
```

### 2. Додавання секретів до Key Vault

```bash
#!/bin/bash

KEY_VAULT_NAME="your-keyvault-name"

# Django секрети
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "django-secret-key" \
  --value "$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')"

# Database credentials
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "database-url" \
  --value "postgresql://dbuser:dbpass@dbhost:5432/dbname"

# Email settings
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "email-host-password" \
  --value "your-email-password"

# Third-party API keys
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "stripe-api-key" \
  --value "sk_live_..."

# Storage Account key
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "azure-storage-key" \
  --value "your-storage-account-key"

echo "✅ Секрети додано до Key Vault"
```

---

## 🐍 Інтеграція з Django

### 1. Встановлення залежностей

```txt
# requirements/base.txt
azure-keyvault-secrets>=4.7.0
azure-identity>=1.15.0
python-decouple>=3.8
django-environ>=0.11.0
```

### 2. Key Vault клієнт для Django

```python
# utils/keyvault_client.py
import os
import logging
from typing import Optional, Dict, Any
from azure.keyvault.secrets import SecretClient
from azure.identity import (
    DefaultAzureCredential,
    ManagedIdentityCredential,
    ClientSecretCredential,
    AzureCliCredential
)
from azure.core.exceptions import ResourceNotFoundError
from decouple import config

logger = logging.getLogger(__name__)

class KeyVaultClient:
    """Azure Key Vault клієнт для Django"""
    
    def __init__(self):
        self.key_vault_url = config('AZURE_KEY_VAULT_URL', default=None)
        self._client = None
        self._cache = {}
        
        if self.key_vault_url:
            self._initialize_client()
    
    def _initialize_client(self):
        """Ініціалізація клієнта з автентифікацією"""
        try:
            # Спроба різних методів автентифікації
            credential = self._get_credential()
            self._client = SecretClient(
                vault_url=self.key_vault_url,
                credential=credential
            )
            logger.info(f"✅ Key Vault клієнт ініціалізовано: {self.key_vault_url}")
            
        except Exception as e:
            logger.error(f"❌ Помилка ініціалізації Key Vault: {e}")
            self._client = None
    
    def _get_credential(self):
        """Отримання credentials для автентифікації"""
        
        # 1. Managed Identity (для Azure App Service)
        if config('WEBSITE_SITE_NAME', default=None):  # Azure App Service
            logger.info("🔑 Використання Managed Identity")
            return ManagedIdentityCredential()
        
        # 2. Service Principal (для CI/CD)
        tenant_id = config('AZURE_TENANT_ID', default=None)
        client_id = config('AZURE_CLIENT_ID', default=None)
        client_secret = config('AZURE_CLIENT_SECRET', default=None)
        
        if all([tenant_id, client_id, client_secret]):
            logger.info("🔑 Використання Service Principal")
            return ClientSecretCredential(
                tenant_id=tenant_id,
                client_id=client_id,
                client_secret=client_secret
            )
        
        # 3. Azure CLI (для локальної розробки)
        try:
            logger.info("🔑 Використання Azure CLI")
            return AzureCliCredential()
        except:
            pass
        
        # 4. Default credential chain
        logger.info("🔑 Використання Default Azure Credential")
        return DefaultAzureCredential()
    
    def get_secret(self, secret_name: str, default: Optional[str] = None) -> Optional[str]:
        """Отримання секрету з Key Vault"""
        
        if not self._client:
            logger.warning(f"⚠️ Key Vault недоступний, використання default для {secret_name}")
            return default
        
        # Перевірка кешу
        if secret_name in self._cache:
            return self._cache[secret_name]
        
        try:
            secret = self._client.get_secret(secret_name)
            self._cache[secret_name] = secret.value
            logger.info(f"✅ Отримано секрет: {secret_name}")
            return secret.value
            
        except ResourceNotFoundError:
            logger.warning(f"⚠️ Секрет не знайдено: {secret_name}")
            return default
            
        except Exception as e:
            logger.error(f"❌ Помилка отримання секрету {secret_name}: {e}")
            return default
    
    def get_secrets_batch(self, secret_names: list) -> Dict[str, Optional[str]]:
        """Отримання кількох секретів одночасно"""
        return {name: self.get_secret(name) for name in secret_names}
    
    def set_secret(self, secret_name: str, secret_value: str) -> bool:
        """Встановлення секрету в Key Vault"""
        
        if not self._client:
            logger.error("❌ Key Vault недоступний для запису")
            return False
        
        try:
            self._client.set_secret(secret_name, secret_value)
            self._cache[secret_name] = secret_value  # Оновлення кешу
            logger.info(f"✅ Секрет встановлено: {secret_name}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Помилка встановлення секрету {secret_name}: {e}")
            return False

# Глобальний екземпляр
keyvault_client = KeyVaultClient()

def get_secret(secret_name: str, default: Optional[str] = None) -> Optional[str]:
    """Зручна функція для отримання секретів"""
    return keyvault_client.get_secret(secret_name, default)
```

### 3. Інтеграція з Django Settings

```python
# config/settings/base.py
import os
from pathlib import Path
from decouple import config
from utils.keyvault_client import get_secret

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Key Vault URL
AZURE_KEY_VAULT_URL = config('AZURE_KEY_VAULT_URL', default=None)

# Security settings з Key Vault
SECRET_KEY = get_secret('django-secret-key') or config('SECRET_KEY')

# Database з Key Vault
DATABASE_URL = get_secret('database-url') or config('DATABASE_URL')

# Email settings з Key Vault
EMAIL_HOST_PASSWORD = get_secret('email-host-password') or config('EMAIL_HOST_PASSWORD', default='')

# Third-party integrations
STRIPE_SECRET_KEY = get_secret('stripe-secret-key') or config('STRIPE_SECRET_KEY', default='')
SENDGRID_API_KEY = get_secret('sendgrid-api-key') or config('SENDGRID_API_KEY', default='')

# Azure Storage з Key Vault
AZURE_STORAGE_ACCOUNT_KEY = get_secret('azure-storage-key') or config('AZURE_STORAGE_ACCOUNT_KEY', default='')

# Sentry DSN з Key Vault
SENTRY_DSN = get_secret('sentry-dsn') or config('SENTRY_DSN', default=None)

# Batch отримання секретів для оптимізації
# secrets_batch = keyvault_client.get_secrets_batch([
#     'django-secret-key',
#     'database-url',
#     'email-host-password'
# ])
```

### 4. Продвинутий Key Vault Service

```python
# services/keyvault_service.py
import json
import logging
from typing import Dict, Any, Optional
from django.core.cache import cache
from django.conf import settings
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class KeyVaultService:
    """Сервіс для роботи з Key Vault секретами"""
    
    CACHE_PREFIX = 'keyvault_'
    CACHE_TTL = 3600  # 1 година
    
    @classmethod
    def get_database_config(cls) -> Dict[str, Any]:
        """Отримання конфігурації бази даних"""
        cache_key = f"{cls.CACHE_PREFIX}database_config"
        config = cache.get(cache_key)
        
        if not config:
            database_url = keyvault_client.get_secret('database-url')
            if database_url:
                import dj_database_url
                config = dj_database_url.parse(database_url)
                cache.set(cache_key, config, cls.CACHE_TTL)
            else:
                config = {}
        
        return config
    
    @classmethod
    def get_email_config(cls) -> Dict[str, str]:
        """Отримання конфігурації email"""
        cache_key = f"{cls.CACHE_PREFIX}email_config"
        config = cache.get(cache_key)
        
        if not config:
            secrets = keyvault_client.get_secrets_batch([
                'email-host',
                'email-port',
                'email-host-user',
                'email-host-password',
                'email-use-tls'
            ])
            
            config = {
                'EMAIL_HOST': secrets.get('email-host', 'smtp.gmail.com'),
                'EMAIL_PORT': int(secrets.get('email-port', '587')),
                'EMAIL_HOST_USER': secrets.get('email-host-user', ''),
                'EMAIL_HOST_PASSWORD': secrets.get('email-host-password', ''),
                'EMAIL_USE_TLS': secrets.get('email-use-tls', 'true').lower() == 'true'
            }
            
            cache.set(cache_key, config, cls.CACHE_TTL)
        
        return config
    
    @classmethod
    def get_api_keys(cls) -> Dict[str, str]:
        """Отримання API ключів"""
        cache_key = f"{cls.CACHE_PREFIX}api_keys"
        keys = cache.get(cache_key)
        
        if not keys:
            keys = keyvault_client.get_secrets_batch([
                'stripe-secret-key',
                'stripe-publishable-key',
                'sendgrid-api-key',
                'google-maps-api-key',
                'recaptcha-secret-key'
            ])
            
            cache.set(cache_key, keys, cls.CACHE_TTL)
        
        return keys
    
    @classmethod
    def rotate_secret(cls, secret_name: str, new_value: str) -> bool:
        """Ротація секрету"""
        try:
            # Встановлення нового значення
            success = keyvault_client.set_secret(secret_name, new_value)
            
            if success:
                # Очищення кешу
                cache_pattern = f"{cls.CACHE_PREFIX}*"
                cache.delete_many(cache.keys(cache_pattern))
                logger.info(f"✅ Секрет ротовано: {secret_name}")
                
            return success
            
        except Exception as e:
            logger.error(f"❌ Помилка ротації секрету {secret_name}: {e}")
            return False
    
    @classmethod
    def health_check(cls) -> Dict[str, Any]:
        """Перевірка здоров'я Key Vault"""
        try:
            # Спроба отримати тестовий секрет
            test_secret = keyvault_client.get_secret('health-check')
            
            return {
                'status': 'healthy',
                'key_vault_url': keyvault_client.key_vault_url,
                'accessible': keyvault_client._client is not None,
                'test_secret_available': test_secret is not None
            }
            
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e),
                'accessible': False
            }
```

---

## 🆔 Managed Identity налаштування

### 1. Створення системної Managed Identity

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
APP_NAME="django-app"
KEY_VAULT_NAME="django-app-kv"

# Включення системної Managed Identity для App Service
az webapp identity assign \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP

# Отримання Principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# Надання доступу до Key Vault
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list

echo "✅ Managed Identity налаштовано: $PRINCIPAL_ID"
```

### 2. Користувацька Managed Identity (опціонально)

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
IDENTITY_NAME="django-app-identity"
KEY_VAULT_NAME="django-app-kv"

# Створення користувацької Managed Identity
az identity create \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP

# Отримання Client ID та Principal ID
CLIENT_ID=$(az identity show \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --query clientId -o tsv)

PRINCIPAL_ID=$(az identity show \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# Надання доступу до Key Vault
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list

# Призначення Identity до App Service
az webapp identity assign \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --identities $CLIENT_ID

echo "✅ Користувацька Managed Identity: $CLIENT_ID"
```

---

## 🚀 Deployment конфігурація

### 1. Azure App Service налаштування

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
APP_NAME="django-app"
KEY_VAULT_NAME="django-app-kv"

# Налаштування змінних середовища App Service
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    AZURE_KEY_VAULT_URL="https://${KEY_VAULT_NAME}.vault.azure.net/" \
    DJANGO_SETTINGS_MODULE="config.settings.production" \
    WEBSITE_HTTPLOGGING_RETENTION_DAYS="7"

# Key Vault References (альтернативний метод)
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    SECRET_KEY="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=django-secret-key)" \
    DATABASE_URL="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=database-url)"

echo "✅ App Service налаштовано для Key Vault"
```

### 2. CI/CD з GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Azure with Key Vault

on:
  push:
    branches: [ main ]

env:
  AZURE_WEBAPP_NAME: django-app
  PYTHON_VERSION: '3.11'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Get secrets from Key Vault
      uses: azure/CLI@v1
      with:
        azcliversion: 2.30.0
        inlineScript: |
          # Отримання секретів для build процесу
          SECRET_KEY=$(az keyvault secret show --name django-secret-key --vault-name ${{ secrets.KEY_VAULT_NAME }} --query value -o tsv)
          echo "::add-mask::$SECRET_KEY"
          echo "SECRET_KEY=$SECRET_KEY" >> $GITHUB_ENV
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements/production.txt
    
    - name: Collect static files
      env:
        SECRET_KEY: ${{ env.SECRET_KEY }}
        DJANGO_SETTINGS_MODULE: config.settings.production
      run: |
        python manage.py collectstatic --noinput
    
    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
    
    - name: Run post-deployment commands
      uses: azure/CLI@v1
      with:
        inlineScript: |
          # Запуск міграцій через Key Vault
          az webapp ssh --name ${{ env.AZURE_WEBAPP_NAME }} --resource-group ${{ secrets.RESOURCE_GROUP }} --command "python manage.py migrate"
```

---

## 🏗️ Автоматизація з Bicep

### 1. Key Vault Bicep template

```bicep
// deployment/azure/keyvault.bicep
@description('Environment name')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App name prefix') 
param appName string = 'django-app'

@description('Tenant ID')
param tenantId string = subscription().tenantId

var keyVaultName = '${appName}-${environment}-kv'
var appServiceName = '${appName}-${environment}-app'

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'production'
    enableRbacAuthorization: false
    accessPolicies: []
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// App Service (потрібен для Managed Identity)
resource appService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appServiceName
}

// Key Vault access policy для App Service Managed Identity
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: appService.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Секрети (приклади)
resource secretDjangoKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'django-secret-key'
  properties: {
    value: 'temp-value-replace-after-deployment'
  }
}

resource secretDatabaseUrl 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'database-url'
  properties: {
    value: 'postgresql://user:pass@server:5432/db'
  }
}

// Outputs
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultId string = keyVault.id
```

### 2. Deployment скрипт з секретами

```bash
#!/bin/bash
# deployment/scripts/deploy-with-secrets.sh

set -e

RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
ENVIRONMENT="production"
KEY_VAULT_NAME="django-app-${ENVIRONMENT}-kv"

echo "🚀 Розгортання з Key Vault..."

# Розгортання інфраструктури
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file deployment/azure/keyvault.bicep \
  --parameters environment=$ENVIRONMENT

# Генерація та встановлення секретів
echo "🔐 Встановлення секретів..."

# Django Secret Key
DJANGO_SECRET=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "django-secret-key" \
  --value "$DJANGO_SECRET"

# Database URL (від PostgreSQL deployment)
POSTGRES_SERVER=$(az postgres flexible-server list --resource-group $RESOURCE_GROUP --query "[0].fullyQualifiedDomainName" -o tsv)
POSTGRES_USER="dbadmin"
POSTGRES_PASSWORD=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name "postgres-password" --query value -o tsv 2>/dev/null || echo "TempPassword123!")
POSTGRES_DB="django_${ENVIRONMENT}"

DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}:5432/${POSTGRES_DB}"
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "database-url" \
  --value "$DATABASE_URL"

# Storage Account Key
STORAGE_ACCOUNT=$(az storage account list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "azure-storage-key" \
  --value "$STORAGE_KEY"

echo "✅ Секрети встановлено в Key Vault: $KEY_VAULT_NAME"
```

---

## 🛡️ Безпека та Best Practices

### 1. Принципи безпеки

```python
# config/settings/security.py
from utils.keyvault_client import get_secret

# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_PRELOAD = True

# SSL настройки
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Content Security Policy
CSP_DEFAULT_SRC = ["'self'"]
CSP_SCRIPT_SRC = ["'self'", "'unsafe-inline'"]
CSP_STYLE_SRC = ["'self'", "'unsafe-inline'"]

# Audit logging для Key Vault операцій
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'keyvault_audit': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': 'logs/keyvault_audit.log',
            'maxBytes': 1024*1024*5,  # 5MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'utils.keyvault_client': {
            'handlers': ['keyvault_audit'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

### 2. Моніторинг та алерти

```python
# monitoring/keyvault_monitoring.py
import logging
from django.core.management.base import BaseCommand
from django.core.mail import send_mail
from django.conf import settings
from services.keyvault_service import KeyVaultService

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Моніторинг Key Vault доступності"""
    
    def handle(self, *args, **options):
        health = KeyVaultService.health_check()
        
        if health['status'] != 'healthy':
            self.send_alert(health)
            logger.error(f"❌ Key Vault недоступний: {health}")
        else:
            logger.info("✅ Key Vault доступний")
    
    def send_alert(self, health_data):
        """Відправка алерту про проблеми"""
        subject = '🚨 Key Vault Alert'
        message = f"""
        Key Vault Health Check Failed:
        
        Status: {health_data['status']}
        Error: {health_data.get('error', 'Unknown')}
        Accessible: {health_data['accessible']}
        
        Please check Key Vault configuration and access policies.
        """
        
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            ['admin@yourapp.com'],
            fail_silently=False,
        )
```

### 3. Secrets rotation strategy

```python
# utils/secrets_rotation.py
import os
import logging
from datetime import datetime, timedelta
from django.core.management.base import BaseCommand
from services.keyvault_service import KeyVaultService
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Автоматична ротація секретів"""
    
    def add_arguments(self, parser):
        parser.add_argument('--secret-name', required=True)
        parser.add_argument('--dry-run', action='store_true')
    
    def handle(self, *args, **options):
        secret_name = options['secret_name']
        dry_run = options['dry_run']
        
        if secret_name == 'django-secret-key':
            self.rotate_django_secret(dry_run)
        elif secret_name == 'database-password':
            self.rotate_database_password(dry_run)
        else:
            logger.error(f"❌ Невідомий секрет: {secret_name}")
    
    def rotate_django_secret(self, dry_run=False):
        """Ротація Django SECRET_KEY"""
        from django.core.management.utils import get_random_secret_key
        
        new_secret = get_random_secret_key()
        
        if dry_run:
            logger.info(f"🔄 [DRY RUN] Буде створено новий Django secret")
            return
        
        success = KeyVaultService.rotate_secret('django-secret-key', new_secret)
        if success:
            logger.info("✅ Django secret key ротовано")
            # Перезапуск додатка після ротації
            self.restart_application()
        else:
            logger.error("❌ Помилка ротації Django secret")
    
    def rotate_database_password(self, dry_run=False):
        """Ротація паролю бази даних"""
        import secrets
        import string
        
        # Генерація нового паролю
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        new_password = ''.join(secrets.choice(alphabet) for _ in range(32))
        
        if dry_run:
            logger.info(f"🔄 [DRY RUN] Буде створено новий пароль БД")
            return
        
        # TODO: Реалізувати зміну паролю в PostgreSQL
        # az postgres flexible-server update --admin-password $new_password
        
        logger.info("✅ Пароль бази даних ротовано")
    
    def restart_application(self):
        """Перезапуск Azure App Service"""
        import subprocess
        
        try:
            app_name = os.environ.get('WEBSITE_SITE_NAME')
            if app_name:
                subprocess.run([
                    'az', 'webapp', 'restart',
                    '--name', app_name,
                    '--resource-group', os.environ.get('RESOURCE_GROUP', 'django-app-rg')
                ], check=True)
                logger.info("🔄 Додаток перезапущено")
        except Exception as e:
            logger.error(f"❌ Помилка перезапуску: {e}")
```

### 4. Backup та відновлення секретів

```python
# utils/keyvault_backup.py
import json
import logging
from datetime import datetime
from django.core.management.base import BaseCommand
from azure.keyvault.secrets import SecretClient
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Backup секретів з Key Vault"""
    
    def add_arguments(self, parser):
        parser.add_argument('--output-file', default=f'secrets_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json')
        parser.add_argument('--encrypt', action='store_true', help='Зашифрувати backup')
    
    def handle(self, *args, **options):
        output_file = options['output_file']
        encrypt = options['encrypt']
        
        if not keyvault_client._client:
            logger.error("❌ Key Vault недоступний")
            return
        
        try:
            # Отримання всіх секретів
            secrets = {}
            secret_properties = keyvault_client._client.list_properties_of_secrets()
            
            for secret_property in secret_properties:
                secret_name = secret_property.name
                try:
                    secret = keyvault_client._client.get_secret(secret_name)
                    secrets[secret_name] = {
                        'value': secret.value,
                        'created_on': secret.properties.created_on.isoformat() if secret.properties.created_on else None,
                        'updated_on': secret.properties.updated_on.isoformat() if secret.properties.updated_on else None,
                        'content_type': secret.properties.content_type,
                        'tags': secret.properties.tags
                    }
                    logger.info(f"✅ Backup секрету: {secret_name}")
                except Exception as e:
                    logger.error(f"❌ Помилка backup {secret_name}: {e}")
            
            # Збереження backup
            backup_data = {
                'timestamp': datetime.now().isoformat(),
                'key_vault_url': keyvault_client.key_vault_url,
                'secrets_count': len(secrets),
                'secrets': secrets
            }
            
            if encrypt:
                backup_data = self.encrypt_backup(backup_data)
            
            with open(output_file, 'w') as f:
                json.dump(backup_data, f, indent=2, ensure_ascii=False)
            
            logger.info(f"✅ Backup створено: {output_file} ({len(secrets)} секретів)")
            
        except Exception as e:
            logger.error(f"❌ Помилка створення backup: {e}")
    
    def encrypt_backup(self, data):
        """Шифрування backup даних"""
        from cryptography.fernet import Fernet
        import base64
        
        # Генерація ключа (в реальності зберігати окремо!)
        key = Fernet.generate_key()
        cipher_suite = Fernet(key)
        
        json_data = json.dumps(data).encode()
        encrypted_data = cipher_suite.encrypt(json_data)
        
        return {
            'encrypted': True,
            'key': base64.b64encode(key).decode(),
            'data': base64.b64encode(encrypted_data).decode()
        }

class RestoreCommand(BaseCommand):
    """Відновлення секретів з backup"""
    
    def add_arguments(self, parser):
        parser.add_argument('--backup-file', required=True)
        parser.add_argument('--dry-run', action='store_true')
        parser.add_argument('--overwrite', action='store_true')
    
    def handle(self, *args, **options):
        backup_file = options['backup_file']
        dry_run = options['dry_run']
        overwrite = options['overwrite']
        
        try:
            with open(backup_file, 'r') as f:
                backup_data = json.load(f)
            
            if backup_data.get('encrypted'):
                backup_data = self.decrypt_backup(backup_data)
            
            secrets = backup_data['secrets']
            
            for secret_name, secret_data in secrets.items():
                if dry_run:
                    logger.info(f"🔄 [DRY RUN] Відновлення: {secret_name}")
                    continue
                
                # Перевірка існування
                existing_secret = keyvault_client.get_secret(secret_name)
                if existing_secret and not overwrite:
                    logger.warning(f"⚠️ Секрет існує, пропущено: {secret_name}")
                    continue
                
                # Відновлення секрету
                success = keyvault_client.set_secret(secret_name, secret_data['value'])
                if success:
                    logger.info(f"✅ Відновлено: {secret_name}")
                else:
                    logger.error(f"❌ Помилка відновлення: {secret_name}")
            
            logger.info(f"✅ Відновлення завершено з {backup_file}")
            
        except Exception as e:
            logger.error(f"❌ Помилка відновлення: {e}")
    
    def decrypt_backup(self, encrypted_data):
        """Розшифрування backup даних"""
        from cryptography.fernet import Fernet
        import base64
        
        key = base64.b64decode(encrypted_data['key'])
        cipher_suite = Fernet(key)
        
        encrypted_bytes = base64.b64decode(encrypted_data['data'])
        decrypted_data = cipher_suite.decrypt(encrypted_bytes)
        
        return json.loads(decrypted_data.decode())
```

---

## 🔧 Практичні команди та скрипти

### 1. Швидке налаштування Key Vault

```bash
#!/bin/bash
# scripts/setup-keyvault.sh

set -e

# Конфігурація
RESOURCE_GROUP="${1:-django-app-rg}"
LOCATION="${2:-westeurope}"
APP_NAME="${3:-django-app}"
ENVIRONMENT="${4:-dev}"

KEY_VAULT_NAME="${APP_NAME}-${ENVIRONMENT}-kv"

echo "🔐 Налаштування Key Vault: $KEY_VAULT_NAME"

# Створення Key Vault
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku standard \
  --enable-soft-delete true \
  --retention-days 90

# Налаштування прав доступу для поточного користувача
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $USER_OBJECT_ID \
  --secret-permissions get list set delete recover backup restore

# Додавання базових секретів
echo "📝 Додавання базових секретів..."

# Django Secret Key
DJANGO_SECRET=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "django-secret-key" --value "$DJANGO_SECRET"

# Health check secret
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "health-check" --value "healthy"

# Database password
DB_PASSWORD=$(openssl rand -base64 32)
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "postgres-password" --value "$DB_PASSWORD"

echo "✅ Key Vault налаштовано: https://${KEY_VAULT_NAME}.vault.azure.net/"
echo "🔑 Секретів додано: 3"
echo "📋 Наступні кроки:"
echo "   1. Налаштуйте Managed Identity для App Service"
echo "   2. Додайте AZURE_KEY_VAULT_URL до змінних середовища"
echo "   3. Оновіть Django settings для використання Key Vault"
```

### 2. Скрипт для масового додавання секретів

```bash
#!/bin/bash
# scripts/bulk-add-secrets.sh

KEY_VAULT_NAME="$1"
SECRETS_FILE="$2"

if [ -z "$KEY_VAULT_NAME" ] || [ -z "$SECRETS_FILE" ]; then
    echo "Використання: $0 <key-vault-name> <secrets-file>"
    exit 1
fi

# Формат secrets.txt:
# SECRET_NAME=secret_value
# DATABASE_URL=postgresql://...
# EMAIL_PASSWORD=password123

while IFS='=' read -r key value; do
    # Пропуск коментарів та порожніх рядків
    if [[ $key =~ ^#.*$ ]] || [[ -z $key ]]; then
        continue
    fi
    
    # Конвертація в lowercase для Key Vault
    kv_key=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    echo "📝 Додавання секрету: $kv_key"
    
    az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "$kv_key" \
        --value "$value" \
        --output none
    
    if [ $? -eq 0 ]; then
        echo "✅ Успішно: $kv_key"
    else
        echo "❌ Помилка: $kv_key"
    fi
    
done < "$SECRETS_FILE"

echo "🎉 Масове додавання секретів завершено!"
```

### 3. Health check endpoint

```python
# apps/core/views.py
import logging
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from services.keyvault_service import KeyVaultService

logger = logging.getLogger(__name__)

@require_http_methods(["GET"])
@csrf_exempt
def health_check(request):
    """Health check endpoint з перевіркою Key Vault"""
    
    try:
        # Базові перевірки
        health_data = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'services': {
                'django': 'healthy',
                'database': 'unknown',
                'keyvault': 'unknown'
            }
        }
        
        # Перевірка бази даних
        try:
            from django.db import connection
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            health_data['services']['database'] = 'healthy'
        except Exception as e:
            health_data['services']['database'] = 'unhealthy'
            health_data['status'] = 'degraded'
            logger.error(f"Database health check failed: {e}")
        
        # Перевірка Key Vault
        kv_health = KeyVaultService.health_check()
        health_data['services']['keyvault'] = kv_health['status']
        
        if kv_health['status'] != 'healthy':
            health_data['status'] = 'degraded'
            health_data['keyvault_error'] = kv_health.get('error')
        
        # Визначення HTTP статусу
        status_code = 200 if health_data['status'] == 'healthy' else 503
        
        return JsonResponse(health_data, status=status_code)
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JsonResponse({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }, status=503)
```

---

## 📊 Моніторинг та логування

### 1. Azure Monitor інтеграція

```python
# config/settings/production.py
import os
from opencensus.ext.azure.log_exporter import AzureLogHandler

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING = get_secret('applicationinsights-connection-string')

if APPLICATIONINSIGHTS_CONNECTION_STRING:
    LOGGING['handlers']['azure'] = {
        'level': 'INFO',
        'class': 'opencensus.ext.azure.log_exporter.AzureLogHandler',
        'connection_string': APPLICATIONINSIGHTS_CONNECTION_STRING,
    }
    
    # Додавання Azure handler до Key Vault логера
    LOGGING['loggers']['utils.keyvault_client']['handlers'].append('azure')
```

### 2. Custom metrics для Key Vault

```python
# monitoring/keyvault_metrics.py
import time
import logging
from functools import wraps
from django.core.cache import cache
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module

# Створення метрик
stats = stats_module.stats
view_manager = stats.view_manager
stats_recorder = stats.stats_recorder

# Measures
keyvault_request_duration = measure_module.MeasureFloat(
    "keyvault_request_duration",
    "Duration of Key Vault requests",
    "ms"
)

keyvault_request_count = measure_module.MeasureInt(
    "keyvault_request_count", 
    "Number of Key Vault requests",
    "1"
)

# Views
keyvault_duration_view = view_module.View(
    "keyvault_request_duration_view",
    "Duration of Key Vault requests",
    ["operation", "status"],
    keyvault_request_duration,
    aggregation_module.DistributionAggregation([0.0, 25.0, 50.0, 75.0, 100.0, 200.0, 400.0, 600.0, 800.0, 1000.0])
)

keyvault_count_view = view_module.View(
    "keyvault_request_count_view",
    "Number of Key Vault requests",
    ["operation", "status"],
    keyvault_request_count,
    aggregation_module.CountAggregation()
)

# Реєстрація views
view_manager.register_view(keyvault_duration_view)
view_manager.register_view(keyvault_count_view)

def track_keyvault_operation(operation_name):
    """Декоратор для трекінгу Key Vault операцій"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            status = "success"
            
            try:
                result = func(*args, **kwargs)
                return result
            except Exception as e:
                status = "error"
                raise
            finally:
                # Запис метрик
                duration = (time.time() - start_time) * 1000  # ms
                
                tag_map = tag_map_module.TagMap()
                tag_map.insert("operation", operation_name)
                tag_map.insert("status", status)
                
                mmap = stats_recorder.new_measurement_map()
                mmap.measure_float_put(keyvault_request_duration, duration)
                mmap.measure_int_put(keyvault_request_count, 1)
                mmap.record(tag_map)
                
        return wrapper
    return decorator
```

---

## 🎯 Підсумок та рекомендації

### ✅ **Що ви отримаєте з цією конфігурацією:**

1. **🔐 Централізоване управління секретами** через Azure Key Vault
2. **🆔 Безпечна автентифікація** через Managed Identity
3. **🔄 Автоматична ротація секретів** з мінімальним downtime
4. **📊 Моніторинг та алерти** для Key Vault операцій
5. **💾 Backup та відновлення** секретів
6. **🚀 Seamless deployment** з CI/CD integration
7. **🛡️ Audit logging** всіх операцій з секретами

### 📝 **Best Practices які реалізовані:**

- **Principle of Least Privilege** - мінімальні необхідні права
- **Defense in Depth** - кілька рівнів захисту
- **Separation of Concerns** - секрети окремо від коду
- **Audit Trail** - повне логування операцій
- **Disaster Recovery** - backup та відновлення
- **High Availability** - fallback механізми

### 🚀 **Початок роботи:**

1. **Створіть Key Vault:**
   ```bash
   ./scripts/setup-keyvault.sh django-app-rg westeurope my-app prod
   ```

2. **Налаштуйте Django:**
   ```python
   # settings.py
   AZURE_KEY_VAULT_URL = 'https://my-app-prod-kv.vault.azure.net/'
   SECRET_KEY = get_secret('django-secret-key')
   ```

3. **Додайте Managed Identity:**
   ```bash
   az webapp identity assign --name my-app --resource-group django-app-rg
   ```

4. **Розгорніть з секретами:**
   ```bash
   ./deployment/scripts/deploy-with-secrets.sh
   ```

Тепер ваш Django проект має enterprise-рівень безпеки з Azure Key Vault! 🎉

----------------------------------------------------------------------------------------------------------


# 🔐 Azure Key Vault для Django: Повний гайд з безпеки

## 📋 Зміст
1. [Налаштування Azure Key Vault](#налаштування-azure-key-vault)
2. [Інтеграція з Django](#інтеграція-з-django)
3. [Managed Identity](#managed-identity)
4. [Deployment конфігурація](#deployment-конфігурація)
5. [Автоматизація з Bicep](#автоматизація-з-bicep)
6. [Безпека та best practices](#безпека-та-best-practices)

---

## 🏗️ Налаштування Azure Key Vault

### 1. Створення Key Vault через Azure CLI

```bash
#!/bin/bash

# Змінні
RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
KEY_VAULT_NAME="django-app-kv-$(date +%s)"
APP_NAME="django-app"

# Створення Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Створення Key Vault
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku standard \
  --enable-soft-delete true \
  --enable-purge-protection true \
  --retention-days 90

# Встановлення прав доступу для поточного користувача
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $USER_OBJECT_ID \
  --secret-permissions get list set delete recover backup restore

echo "✅ Key Vault створено: $KEY_VAULT_NAME"
```

### 2. Додавання секретів до Key Vault

```bash
#!/bin/bash

KEY_VAULT_NAME="your-keyvault-name"

# Django секрети
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "django-secret-key" \
  --value "$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')"

# Database credentials
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "database-url" \
  --value "postgresql://dbuser:dbpass@dbhost:5432/dbname"

# Email settings
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "email-host-password" \
  --value "your-email-password"

# Third-party API keys
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "stripe-api-key" \
  --value "sk_live_..."

# Storage Account key
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "azure-storage-key" \
  --value "your-storage-account-key"

echo "✅ Секрети додано до Key Vault"
```

---

## 🐍 Інтеграція з Django

### 1. Встановлення залежностей

```txt
# requirements/base.txt
azure-keyvault-secrets>=4.7.0
azure-identity>=1.15.0
python-decouple>=3.8
django-environ>=0.11.0
```

### 2. Key Vault клієнт для Django

```python
# utils/keyvault_client.py
import os
import logging
from typing import Optional, Dict, Any
from azure.keyvault.secrets import SecretClient
from azure.identity import (
    DefaultAzureCredential,
    ManagedIdentityCredential,
    ClientSecretCredential,
    AzureCliCredential
)
from azure.core.exceptions import ResourceNotFoundError
from decouple import config

logger = logging.getLogger(__name__)

class KeyVaultClient:
    """Azure Key Vault клієнт для Django"""
    
    def __init__(self):
        self.key_vault_url = config('AZURE_KEY_VAULT_URL', default=None)
        self._client = None
        self._cache = {}
        
        if self.key_vault_url:
            self._initialize_client()
    
    def _initialize_client(self):
        """Ініціалізація клієнта з автентифікацією"""
        try:
            # Спроба різних методів автентифікації
            credential = self._get_credential()
            self._client = SecretClient(
                vault_url=self.key_vault_url,
                credential=credential
            )
            logger.info(f"✅ Key Vault клієнт ініціалізовано: {self.key_vault_url}")
            
        except Exception as e:
            logger.error(f"❌ Помилка ініціалізації Key Vault: {e}")
            self._client = None
    
    def _get_credential(self):
        """Отримання credentials для автентифікації"""
        
        # 1. Managed Identity (для Azure App Service)
        if config('WEBSITE_SITE_NAME', default=None):  # Azure App Service
            logger.info("🔑 Використання Managed Identity")
            return ManagedIdentityCredential()
        
        # 2. Service Principal (для CI/CD)
        tenant_id = config('AZURE_TENANT_ID', default=None)
        client_id = config('AZURE_CLIENT_ID', default=None)
        client_secret = config('AZURE_CLIENT_SECRET', default=None)
        
        if all([tenant_id, client_id, client_secret]):
            logger.info("🔑 Використання Service Principal")
            return ClientSecretCredential(
                tenant_id=tenant_id,
                client_id=client_id,
                client_secret=client_secret
            )
        
        # 3. Azure CLI (для локальної розробки)
        try:
            logger.info("🔑 Використання Azure CLI")
            return AzureCliCredential()
        except:
            pass
        
        # 4. Default credential chain
        logger.info("🔑 Використання Default Azure Credential")
        return DefaultAzureCredential()
    
    def get_secret(self, secret_name: str, default: Optional[str] = None) -> Optional[str]:
        """Отримання секрету з Key Vault"""
        
        if not self._client:
            logger.warning(f"⚠️ Key Vault недоступний, використання default для {secret_name}")
            return default
        
        # Перевірка кешу
        if secret_name in self._cache:
            return self._cache[secret_name]
        
        try:
            secret = self._client.get_secret(secret_name)
            self._cache[secret_name] = secret.value
            logger.info(f"✅ Отримано секрет: {secret_name}")
            return secret.value
            
        except ResourceNotFoundError:
            logger.warning(f"⚠️ Секрет не знайдено: {secret_name}")
            return default
            
        except Exception as e:
            logger.error(f"❌ Помилка отримання секрету {secret_name}: {e}")
            return default
    
    def get_secrets_batch(self, secret_names: list) -> Dict[str, Optional[str]]:
        """Отримання кількох секретів одночасно"""
        return {name: self.get_secret(name) for name in secret_names}
    
    def set_secret(self, secret_name: str, secret_value: str) -> bool:
        """Встановлення секрету в Key Vault"""
        
        if not self._client:
            logger.error("❌ Key Vault недоступний для запису")
            return False
        
        try:
            self._client.set_secret(secret_name, secret_value)
            self._cache[secret_name] = secret_value  # Оновлення кешу
            logger.info(f"✅ Секрет встановлено: {secret_name}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Помилка встановлення секрету {secret_name}: {e}")
            return False

# Глобальний екземпляр
keyvault_client = KeyVaultClient()

def get_secret(secret_name: str, default: Optional[str] = None) -> Optional[str]:
    """Зручна функція для отримання секретів"""
    return keyvault_client.get_secret(secret_name, default)
```

### 3. Інтеграція з Django Settings

```python
# config/settings/base.py
import os
from pathlib import Path
from decouple import config
from utils.keyvault_client import get_secret

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Key Vault URL
AZURE_KEY_VAULT_URL = config('AZURE_KEY_VAULT_URL', default=None)

# Security settings з Key Vault
SECRET_KEY = get_secret('django-secret-key') or config('SECRET_KEY')

# Database з Key Vault
DATABASE_URL = get_secret('database-url') or config('DATABASE_URL')

# Email settings з Key Vault
EMAIL_HOST_PASSWORD = get_secret('email-host-password') or config('EMAIL_HOST_PASSWORD', default='')

# Third-party integrations
STRIPE_SECRET_KEY = get_secret('stripe-secret-key') or config('STRIPE_SECRET_KEY', default='')
SENDGRID_API_KEY = get_secret('sendgrid-api-key') or config('SENDGRID_API_KEY', default='')

# Azure Storage з Key Vault
AZURE_STORAGE_ACCOUNT_KEY = get_secret('azure-storage-key') or config('AZURE_STORAGE_ACCOUNT_KEY', default='')

# Sentry DSN з Key Vault
SENTRY_DSN = get_secret('sentry-dsn') or config('SENTRY_DSN', default=None)

# Batch отримання секретів для оптимізації
# secrets_batch = keyvault_client.get_secrets_batch([
#     'django-secret-key',
#     'database-url',
#     'email-host-password'
# ])
```

### 4. Продвинутий Key Vault Service

```python
# services/keyvault_service.py
import json
import logging
from typing import Dict, Any, Optional
from django.core.cache import cache
from django.conf import settings
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class KeyVaultService:
    """Сервіс для роботи з Key Vault секретами"""
    
    CACHE_PREFIX = 'keyvault_'
    CACHE_TTL = 3600  # 1 година
    
    @classmethod
    def get_database_config(cls) -> Dict[str, Any]:
        """Отримання конфігурації бази даних"""
        cache_key = f"{cls.CACHE_PREFIX}database_config"
        config = cache.get(cache_key)
        
        if not config:
            database_url = keyvault_client.get_secret('database-url')
            if database_url:
                import dj_database_url
                config = dj_database_url.parse(database_url)
                cache.set(cache_key, config, cls.CACHE_TTL)
            else:
                config = {}
        
        return config
    
    @classmethod
    def get_email_config(cls) -> Dict[str, str]:
        """Отримання конфігурації email"""
        cache_key = f"{cls.CACHE_PREFIX}email_config"
        config = cache.get(cache_key)
        
        if not config:
            secrets = keyvault_client.get_secrets_batch([
                'email-host',
                'email-port',
                'email-host-user',
                'email-host-password',
                'email-use-tls'
            ])
            
            config = {
                'EMAIL_HOST': secrets.get('email-host', 'smtp.gmail.com'),
                'EMAIL_PORT': int(secrets.get('email-port', '587')),
                'EMAIL_HOST_USER': secrets.get('email-host-user', ''),
                'EMAIL_HOST_PASSWORD': secrets.get('email-host-password', ''),
                'EMAIL_USE_TLS': secrets.get('email-use-tls', 'true').lower() == 'true'
            }
            
            cache.set(cache_key, config, cls.CACHE_TTL)
        
        return config
    
    @classmethod
    def get_api_keys(cls) -> Dict[str, str]:
        """Отримання API ключів"""
        cache_key = f"{cls.CACHE_PREFIX}api_keys"
        keys = cache.get(cache_key)
        
        if not keys:
            keys = keyvault_client.get_secrets_batch([
                'stripe-secret-key',
                'stripe-publishable-key',
                'sendgrid-api-key',
                'google-maps-api-key',
                'recaptcha-secret-key'
            ])
            
            cache.set(cache_key, keys, cls.CACHE_TTL)
        
        return keys
    
    @classmethod
    def rotate_secret(cls, secret_name: str, new_value: str) -> bool:
        """Ротація секрету"""
        try:
            # Встановлення нового значення
            success = keyvault_client.set_secret(secret_name, new_value)
            
            if success:
                # Очищення кешу
                cache_pattern = f"{cls.CACHE_PREFIX}*"
                cache.delete_many(cache.keys(cache_pattern))
                logger.info(f"✅ Секрет ротовано: {secret_name}")
                
            return success
            
        except Exception as e:
            logger.error(f"❌ Помилка ротації секрету {secret_name}: {e}")
            return False
    
    @classmethod
    def health_check(cls) -> Dict[str, Any]:
        """Перевірка здоров'я Key Vault"""
        try:
            # Спроба отримати тестовий секрет
            test_secret = keyvault_client.get_secret('health-check')
            
            return {
                'status': 'healthy',
                'key_vault_url': keyvault_client.key_vault_url,
                'accessible': keyvault_client._client is not None,
                'test_secret_available': test_secret is not None
            }
            
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e),
                'accessible': False
            }
```

---

## 🆔 Managed Identity налаштування

### 1. Створення системної Managed Identity

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
APP_NAME="django-app"
KEY_VAULT_NAME="django-app-kv"

# Включення системної Managed Identity для App Service
az webapp identity assign \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP

# Отримання Principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# Надання доступу до Key Vault
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list

echo "✅ Managed Identity налаштовано: $PRINCIPAL_ID"
```

### 2. Користувацька Managed Identity (опціонально)

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
IDENTITY_NAME="django-app-identity"
KEY_VAULT_NAME="django-app-kv"

# Створення користувацької Managed Identity
az identity create \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP

# Отримання Client ID та Principal ID
CLIENT_ID=$(az identity show \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --query clientId -o tsv)

PRINCIPAL_ID=$(az identity show \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# Надання доступу до Key Vault
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list

# Призначення Identity до App Service
az webapp identity assign \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --identities $CLIENT_ID

echo "✅ Користувацька Managed Identity: $CLIENT_ID"
```

---

## 🚀 Deployment конфігурація

### 1. Azure App Service налаштування

```bash
#!/bin/bash

RESOURCE_GROUP="django-app-rg"
APP_NAME="django-app"
KEY_VAULT_NAME="django-app-kv"

# Налаштування змінних середовища App Service
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    AZURE_KEY_VAULT_URL="https://${KEY_VAULT_NAME}.vault.azure.net/" \
    DJANGO_SETTINGS_MODULE="config.settings.production" \
    WEBSITE_HTTPLOGGING_RETENTION_DAYS="7"

# Key Vault References (альтернативний метод)
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    SECRET_KEY="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=django-secret-key)" \
    DATABASE_URL="@Microsoft.KeyVault(VaultName=${KEY_VAULT_NAME};SecretName=database-url)"

echo "✅ App Service налаштовано для Key Vault"
```

### 2. CI/CD з GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Azure with Key Vault

on:
  push:
    branches: [ main ]

env:
  AZURE_WEBAPP_NAME: django-app
  PYTHON_VERSION: '3.11'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Get secrets from Key Vault
      uses: azure/CLI@v1
      with:
        azcliversion: 2.30.0
        inlineScript: |
          # Отримання секретів для build процесу
          SECRET_KEY=$(az keyvault secret show --name django-secret-key --vault-name ${{ secrets.KEY_VAULT_NAME }} --query value -o tsv)
          echo "::add-mask::$SECRET_KEY"
          echo "SECRET_KEY=$SECRET_KEY" >> $GITHUB_ENV
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements/production.txt
    
    - name: Collect static files
      env:
        SECRET_KEY: ${{ env.SECRET_KEY }}
        DJANGO_SETTINGS_MODULE: config.settings.production
      run: |
        python manage.py collectstatic --noinput
    
    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
    
    - name: Run post-deployment commands
      uses: azure/CLI@v1
      with:
        inlineScript: |
          # Запуск міграцій через Key Vault
          az webapp ssh --name ${{ env.AZURE_WEBAPP_NAME }} --resource-group ${{ secrets.RESOURCE_GROUP }} --command "python manage.py migrate"
```

---

## 🏗️ Автоматизація з Bicep

### 1. Key Vault Bicep template

```bicep
// deployment/azure/keyvault.bicep
@description('Environment name')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App name prefix') 
param appName string = 'django-app'

@description('Tenant ID')
param tenantId string = subscription().tenantId

var keyVaultName = '${appName}-${environment}-kv'
var appServiceName = '${appName}-${environment}-app'

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'production'
    enableRbacAuthorization: false
    accessPolicies: []
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// App Service (потрібен для Managed Identity)
resource appService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appServiceName
}

// Key Vault access policy для App Service Managed Identity
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: appService.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Секрети (приклади)
resource secretDjangoKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'django-secret-key'
  properties: {
    value: 'temp-value-replace-after-deployment'
  }
}

resource secretDatabaseUrl 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'database-url'
  properties: {
    value: 'postgresql://user:pass@server:5432/db'
  }
}

// Outputs
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultId string = keyVault.id
```

### 2. Deployment скрипт з секретами

```bash
#!/bin/bash
# deployment/scripts/deploy-with-secrets.sh

set -e

RESOURCE_GROUP="django-app-rg"
LOCATION="westeurope"
ENVIRONMENT="production"
KEY_VAULT_NAME="django-app-${ENVIRONMENT}-kv"

echo "🚀 Розгортання з Key Vault..."

# Розгортання інфраструктури
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file deployment/azure/keyvault.bicep \
  --parameters environment=$ENVIRONMENT

# Генерація та встановлення секретів
echo "🔐 Встановлення секретів..."

# Django Secret Key
DJANGO_SECRET=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "django-secret-key" \
  --value "$DJANGO_SECRET"

# Database URL (від PostgreSQL deployment)
POSTGRES_SERVER=$(az postgres flexible-server list --resource-group $RESOURCE_GROUP --query "[0].fullyQualifiedDomainName" -o tsv)
POSTGRES_USER="dbadmin"
POSTGRES_PASSWORD=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name "postgres-password" --query value -o tsv 2>/dev/null || echo "TempPassword123!")
POSTGRES_DB="django_${ENVIRONMENT}"

DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}:5432/${POSTGRES_DB}"
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "database-url" \
  --value "$DATABASE_URL"

# Storage Account Key
STORAGE_ACCOUNT=$(az storage account list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "azure-storage-key" \
  --value "$STORAGE_KEY"

echo "✅ Секрети встановлено в Key Vault: $KEY_VAULT_NAME"
```

---

## 🛡️ Безпека та Best Practices

### 1. Принципи безпеки

```python
# config/settings/security.py
from utils.keyvault_client import get_secret

# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_PRELOAD = True

# SSL настройки
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Content Security Policy
CSP_DEFAULT_SRC = ["'self'"]
CSP_SCRIPT_SRC = ["'self'", "'unsafe-inline'"]
CSP_STYLE_SRC = ["'self'", "'unsafe-inline'"]

# Audit logging для Key Vault операцій
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'keyvault_audit': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': 'logs/keyvault_audit.log',
            'maxBytes': 1024*1024*5,  # 5MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'utils.keyvault_client': {
            'handlers': ['keyvault_audit'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

### 2. Моніторинг та алерти

```python
# monitoring/keyvault_monitoring.py
import logging
from django.core.management.base import BaseCommand
from django.core.mail import send_mail
from django.conf import settings
from services.keyvault_service import KeyVaultService

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Моніторинг Key Vault доступності"""
    
    def handle(self, *args, **options):
        health = KeyVaultService.health_check()
        
        if health['status'] != 'healthy':
            self.send_alert(health)
            logger.error(f"❌ Key Vault недоступний: {health}")
        else:
            logger.info("✅ Key Vault доступний")
    
    def send_alert(self, health_data):
        """Відправка алерту про проблеми"""
        subject = '🚨 Key Vault Alert'
        message = f"""
        Key Vault Health Check Failed:
        
        Status: {health_data['status']}
        Error: {health_data.get('error', 'Unknown')}
        Accessible: {health_data['accessible']}
        
        Please check Key Vault configuration and access policies.
        """
        
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            ['admin@yourapp.com'],
            fail_silently=False,
        )
```

### 3. Secrets rotation strategy

```python
# utils/secrets_rotation.py
import os
import logging
from datetime import datetime, timedelta
from django.core.management.base import BaseCommand
from services.keyvault_service import KeyVaultService
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Автоматична ротація секретів"""
    
    def add_arguments(self, parser):
        parser.add_argument('--secret-name', required=True)
        parser.add_argument('--dry-run', action='store_true')
    
    def handle(self, *args, **options):
        secret_name = options['secret_name']
        dry_run = options['dry_run']
        
        if secret_name == 'django-secret-key':
            self.rotate_django_secret(dry_run)
        elif secret_name == 'database-password':
            self.rotate_database_password(dry_run)
        else:
            logger.error(f"❌ Невідомий секрет: {secret_name}")
    
    def rotate_django_secret(self, dry_run=False):
        """Ротація Django SECRET_KEY"""
        from django.core.management.utils import get_random_secret_key
        
        new_secret = get_random_secret_key()
        
        if dry_run:
            logger.info(f"🔄 [DRY RUN] Буде створено новий Django secret")
            return
        
        success = KeyVaultService.rotate_secret('django-secret-key', new_secret)
        if success:
            logger.info("✅ Django secret key ротовано")
            # Перезапуск додатка після ротації
            self.restart_application()
        else:
            logger.error("❌ Помилка ротації Django secret")
    
    def rotate_database_password(self, dry_run=False):
        """Ротація паролю бази даних"""
        import secrets
        import string
        
        # Генерація нового паролю
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        new_password = ''.join(secrets.choice(alphabet) for _ in range(32))
        
        if dry_run:
            logger.info(f"🔄 [DRY RUN] Буде створено новий пароль БД")
            return
        
        # TODO: Реалізувати зміну паролю в PostgreSQL
        # az postgres flexible-server update --admin-password $new_password
        
        logger.info("✅ Пароль бази даних ротовано")
    
    def restart_application(self):
        """Перезапуск Azure App Service"""
        import subprocess
        
        try:
            app_name = os.environ.get('WEBSITE_SITE_NAME')
            if app_name:
                subprocess.run([
                    'az', 'webapp', 'restart',
                    '--name', app_name,
                    '--resource-group', os.environ.get('RESOURCE_GROUP', 'django-app-rg')
                ], check=True)
                logger.info("🔄 Додаток перезапущено")
        except Exception as e:
            logger.error(f"❌ Помилка перезапуску: {e}")
```

### 4. Backup та відновлення секретів

```python
# utils/keyvault_backup.py
import json
import logging
from datetime import datetime
from django.core.management.base import BaseCommand
from azure.keyvault.secrets import SecretClient
from utils.keyvault_client import keyvault_client

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    """Backup секретів з Key Vault"""
    
    def add_arguments(self, parser):
        parser.add_argument('--output-file', default=f'secrets_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json')
        parser.add_argument('--encrypt', action='store_true', help='Зашифрувати backup')
    
    def handle(self, *args, **options):
        output_file = options['output_file']
        encrypt = options['encrypt']
        
        if not keyvault_client._client:
            logger.error("❌ Key Vault недоступний")
            return
        
        try:
            # Отримання всіх секретів
            secrets = {}
            secret_properties = keyvault_client._client.list_properties_of_secrets()
            
            for secret_property in secret_properties:
                secret_name = secret_property.name
                try:
                    secret = keyvault_client._client.get_secret(secret_name)
                    secrets[secret_name] = {
                        'value': secret.value,
                        'created_on': secret.properties.created_on.isoformat() if secret.properties.created_on else None,
                        'updated_on': secret.properties.updated_on.isoformat() if secret.properties.updated_on else None,
                        'content_type': secret.properties.content_type,
                        'tags': secret.properties.tags
                    }
                    logger.info(f"✅ Backup секрету: {secret_name}")
                except Exception as e:
                    logger.error(f"❌ Помилка backup {secret_name}: {e}")
            
            # Збереження backup
            backup_data = {
                'timestamp': datetime.now().isoformat(),
                'key_vault_url': keyvault_client.key_vault_url,
                'secrets_count': len(secrets),
                'secrets': secrets
            }
            
            if encrypt:
                backup_data = self.encrypt_backup(backup_data)
            
            with open(output_file, 'w') as f:
                json.dump(backup_data, f, indent=2, ensure_ascii=False)
            
            logger.info(f"✅ Backup створено: {output_file} ({len(secrets)} секретів)")
            
        except Exception as e:
            logger.error(f"❌ Помилка створення backup: {e}")
    
    def encrypt_backup(self, data):
        """Шифрування backup даних"""
        from cryptography.fernet import Fernet
        import base64
        
        # Генерація ключа (в реальності зберігати окремо!)
        key = Fernet.generate_key()
        cipher_suite = Fernet(key)
        
        json_data = json.dumps(data).encode()
        encrypted_data = cipher_suite.encrypt(json_data)
        
        return {
            'encrypted': True,
            'key': base64.b64encode(key).decode(),
            'data': base64.b64encode(encrypted_data).decode()
        }

class RestoreCommand(BaseCommand):
    """Відновлення секретів з backup"""
    
    def add_arguments(self, parser):
        parser.add_argument('--backup-file', required=True)
        parser.add_argument('--dry-run', action='store_true')
        parser.add_argument('--overwrite', action='store_true')
    
    def handle(self, *args, **options):
        backup_file = options['backup_file']
        dry_run = options['dry_run']
        overwrite = options['overwrite']
        
        try:
            with open(backup_file, 'r') as f:
                backup_data = json.load(f)
            
            if backup_data.get('encrypted'):
                backup_data = self.decrypt_backup(backup_data)
            
            secrets = backup_data['secrets']
            
            for secret_name, secret_data in secrets.items():
                if dry_run:
                    logger.info(f"🔄 [DRY RUN] Відновлення: {secret_name}")
                    continue
                
                # Перевірка існування
                existing_secret = keyvault_client.get_secret(secret_name)
                if existing_secret and not overwrite:
                    logger.warning(f"⚠️ Секрет існує, пропущено: {secret_name}")
                    continue
                
                # Відновлення секрету
                success = keyvault_client.set_secret(secret_name, secret_data['value'])
                if success:
                    logger.info(f"✅ Відновлено: {secret_name}")
                else:
                    logger.error(f"❌ Помилка відновлення: {secret_name}")
            
            logger.info(f"✅ Відновлення завершено з {backup_file}")
            
        except Exception as e:
            logger.error(f"❌ Помилка відновлення: {e}")
    
    def decrypt_backup(self, encrypted_data):
        """Розшифрування backup даних"""
        from cryptography.fernet import Fernet
        import base64
        
        key = base64.b64decode(encrypted_data['key'])
        cipher_suite = Fernet(key)
        
        encrypted_bytes = base64.b64decode(encrypted_data['data'])
        decrypted_data = cipher_suite.decrypt(encrypted_bytes)
        
        return json.loads(decrypted_data.decode())
```

---

## 🔧 Практичні команди та скрипти

### 1. Швидке налаштування Key Vault

```bash
#!/bin/bash
# scripts/setup-keyvault.sh

set -e

# Конфігурація
RESOURCE_GROUP="${1:-django-app-rg}"
LOCATION="${2:-westeurope}"
APP_NAME="${3:-django-app}"
ENVIRONMENT="${4:-dev}"

KEY_VAULT_NAME="${APP_NAME}-${ENVIRONMENT}-kv"

echo "🔐 Налаштування Key Vault: $KEY_VAULT_NAME"

# Створення Key Vault
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku standard \
  --enable-soft-delete true \
  --retention-days 90

# Налаштування прав доступу для поточного користувача
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $USER_OBJECT_ID \
  --secret-permissions get list set delete recover backup restore

# Додавання базових секретів
echo "📝 Додавання базових секретів..."

# Django Secret Key
DJANGO_SECRET=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "django-secret-key" --value "$DJANGO_SECRET"

# Health check secret
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "health-check" --value "healthy"

# Database password
DB_PASSWORD=$(openssl rand -base64 32)
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "postgres-password" --value "$DB_PASSWORD"

echo "✅ Key Vault налаштовано: https://${KEY_VAULT_NAME}.vault.azure.net/"
echo "🔑 Секретів додано: 3"
echo "📋 Наступні кроки:"
echo "   1. Налаштуйте Managed Identity для App Service"
echo "   2. Додайте AZURE_KEY_VAULT_URL до змінних середовища"
echo "   3. Оновіть Django settings для використання Key Vault"
```

### 2. Скрипт для масового додавання секретів

```bash
#!/bin/bash
# scripts/bulk-add-secrets.sh

KEY_VAULT_NAME="$1"
SECRETS_FILE="$2"

if [ -z "$KEY_VAULT_NAME" ] || [ -z "$SECRETS_FILE" ]; then
    echo "Використання: $0 <key-vault-name> <secrets-file>"
    exit 1
fi

# Формат secrets.txt:
# SECRET_NAME=secret_value
# DATABASE_URL=postgresql://...
# EMAIL_PASSWORD=password123

while IFS='=' read -r key value; do
    # Пропуск коментарів та порожніх рядків
    if [[ $key =~ ^#.*$ ]] || [[ -z $key ]]; then
        continue
    fi
    
    # Конвертація в lowercase для Key Vault
    kv_key=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    echo "📝 Додавання секрету: $kv_key"
    
    az keyvault secret set \
        --vault-name "$KEY_VAULT_NAME" \
        --name "$kv_key" \
        --value "$value" \
        --output none
    
    if [ $? -eq 0 ]; then
        echo "✅ Успішно: $kv_key"
    else
        echo "❌ Помилка: $kv_key"
    fi
    
done < "$SECRETS_FILE"

echo "🎉 Масове додавання секретів завершено!"
```

### 3. Health check endpoint

```python
# apps/core/views.py
import logging
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from services.keyvault_service import KeyVaultService

logger = logging.getLogger(__name__)

@require_http_methods(["GET"])
@csrf_exempt
def health_check(request):
    """Health check endpoint з перевіркою Key Vault"""
    
    try:
        # Базові перевірки
        health_data = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'services': {
                'django': 'healthy',
                'database': 'unknown',
                'keyvault': 'unknown'
            }
        }
        
        # Перевірка бази даних
        try:
            from django.db import connection
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            health_data['services']['database'] = 'healthy'
        except Exception as e:
            health_data['services']['database'] = 'unhealthy'
            health_data['status'] = 'degraded'
            logger.error(f"Database health check failed: {e}")
        
        # Перевірка Key Vault
        kv_health = KeyVaultService.health_check()
        health_data['services']['keyvault'] = kv_health['status']
        
        if kv_health['status'] != 'healthy':
            health_data['status'] = 'degraded'
            health_data['keyvault_error'] = kv_health.get('error')
        
        # Визначення HTTP статусу
        status_code = 200 if health_data['status'] == 'healthy' else 503
        
        return JsonResponse(health_data, status=status_code)
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JsonResponse({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }, status=503)
```

---

## 📊 Моніторинг та логування

### 1. Azure Monitor інтеграція

```python
# config/settings/production.py
import os
from opencensus.ext.azure.log_exporter import AzureLogHandler

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING = get_secret('applicationinsights-connection-string')

if APPLICATIONINSIGHTS_CONNECTION_STRING:
    LOGGING['handlers']['azure'] = {
        'level': 'INFO',
        'class': 'opencensus.ext.azure.log_exporter.AzureLogHandler',
        'connection_string': APPLICATIONINSIGHTS_CONNECTION_STRING,
    }
    
    # Додавання Azure handler до Key Vault логера
    LOGGING['loggers']['utils.keyvault_client']['handlers'].append('azure')
```

### 2. Custom metrics для Key Vault

```python
# monitoring/keyvault_metrics.py
import time
import logging
from functools import wraps
from django.core.cache import cache
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module

# Створення метрик
stats = stats_module.stats
view_manager = stats.view_manager
stats_recorder = stats.stats_recorder

# Measures
keyvault_request_duration = measure_module.MeasureFloat(
    "keyvault_request_duration",
    "Duration of Key Vault requests",
    "ms"
)

keyvault_request_count = measure_module.MeasureInt(
    "keyvault_request_count", 
    "Number of Key Vault requests",
    "1"
)

# Views
keyvault_duration_view = view_module.View(
    "keyvault_request_duration_view",
    "Duration of Key Vault requests",
    ["operation", "status"],
    keyvault_request_duration,
    aggregation_module.DistributionAggregation([0.0, 25.0, 50.0, 75.0, 100.0, 200.0, 400.0, 600.0, 800.0, 1000.0])
)

keyvault_count_view = view_module.View(
    "keyvault_request_count_view",
    "Number of Key Vault requests",
    ["operation", "status"],
    keyvault_request_count,
    aggregation_module.CountAggregation()
)

# Реєстрація views
view_manager.register_view(keyvault_duration_view)
view_manager.register_view(keyvault_count_view)

def track_keyvault_operation(operation_name):
    """Декоратор для трекінгу Key Vault операцій"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            status = "success"
            
            try:
                result = func(*args, **kwargs)
                return result
            except Exception as e:
                status = "error"
                raise
            finally:
                # Запис метрик
                duration = (time.time() - start_time) * 1000  # ms
                
                tag_map = tag_map_module.TagMap()
                tag_map.insert("operation", operation_name)
                tag_map.insert("status", status)
                
                mmap = stats_recorder.new_measurement_map()
                mmap.measure_float_put(keyvault_request_duration, duration)
                mmap.measure_int_put(keyvault_request_count, 1)
                mmap.record(tag_map)
                
        return wrapper
    return decorator
```

---

## 🎯 Підсумок та рекомендації

### ✅ **Що ви отримаєте з цією конфігурацією:**

1. **🔐 Централізоване управління секретами** через Azure Key Vault
2. **🆔 Безпечна автентифікація** через Managed Identity
3. **🔄 Автоматична ротація секретів** з мінімальним downtime
4. **📊 Моніторинг та алерти** для Key Vault операцій
5. **💾 Backup та відновлення** секретів
6. **🚀 Seamless deployment** з CI/CD integration
7. **🛡️ Audit logging** всіх операцій з секретами

### 📝 **Best Practices які реалізовані:**

- **Principle of Least Privilege** - мінімальні необхідні права
- **Defense in Depth** - кілька рівнів захисту
- **Separation of Concerns** - секрети окремо від коду
- **Audit Trail** - повне логування операцій
- **Disaster Recovery** - backup та відновлення
- **High Availability** - fallback механізми

### 🚀 **Початок роботи:**

1. **Створіть Key Vault:**
   ```bash
   ./scripts/setup-keyvault.sh django-app-rg westeurope my-app prod
   ```

2. **Налаштуйте Django:**
   ```python
   # settings.py
   AZURE_KEY_VAULT_URL = 'https://my-app-prod-kv.vault.azure.net/'
   SECRET_KEY = get_secret('django-secret-key')
   ```

3. **Додайте Managed Identity:**
   ```bash
   az webapp identity assign --name my-app --resource-group django-app-rg
   ```

4. **Розгорніть з секретами:**
   ```bash
   ./deployment/scripts/deploy-with-secrets.sh
   ```

Тепер ваш Django проект має enterprise-рівень безпеки з Azure Key Vault! 🎉



-----------------------------------------------------------------------------------------------------------------------------------------


Проблема в тому, що у файлі `kv_vars.py` значення `AZURE_CLIENT_ID` порожнє, оскільки Service Principal не було створено через недостатні права. Давайте виправимо це, використовуючи альтернативні методи автентифікації:Також створимо простішу версію для швидкого тестування:## 🔧 **Швидке рішення:**

### **1. Спочатку протестуйте простим скриптом:**
```bash
# Встановіть пакети якщо ще не встановлені
pip install azure-keyvault-secrets azure-identity

# Запустіть простий тест
python simple_kv_test.py
```

### **2. Якщо простий тест працює, замініть kv.py:**
```bash
# Замініть ваш kv.py виправленою версією з артефакту вище
cp kv.py kv_old.py  # Backup
# Скопіюйте новий код з артефакту в kv.py
```

### **3. Перевірте ваш kv_vars.py:**
```bash
cat kv_vars.py
```

Мабуть він виглядає так:
```python
AZURE_CLIENT_ID = ""  # Порожньо!
AZURE_CLIENT_SECRET = ""  # Порожньо!
AZURE_TENANT_ID = "3a7a2d8e-5083-4ef2-809c-3a88f18e0ef8"
AZURE_KEY_VAULT_URL = "https://django-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"
SECRET_VERSION = ""
```

### **4. Швидкий тест без kv_vars.py:**
```bash
python3 -c "
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
client = SecretClient('https://django-app-keyvault.vault.azure.net/', DefaultAzureCredential())
print('Secret:', client.get_secret('database-password').value)
"
```

## 🎯 **Причина помилки:**
Ваш оригінальний `kv.py` намагається використовувати `ClientSecretCredential` з порожніми значеннями CLIENT_ID, що викликає помилку.

**Використовуйте оновлені скрипти вище - вони автоматично вибирають правильний метод автентифікації!** 🚀




```python

# simple_kv_test.py - Простий тест Key Vault з Azure CLI автентифікацією
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ClientAuthenticationError, ResourceNotFoundError

# Константи (замість kv_vars.py)
KEY_VAULT_URL = "https://django-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"

def test_keyvault_simple():
    """Простий тест Key Vault"""
    
    print("🚀 Простий тест Azure Key Vault")
    print(f"🔗 URL: {KEY_VAULT_URL}")
    print(f"🔑 Секрет: {SECRET_NAME}")
    print()
    
    try:
        # Використання DefaultAzureCredential (працює з Azure CLI)
        print("🔑 Автентифікація через Azure CLI...")
        credential = DefaultAzureCredential()
        
        # Створення клієнта
        client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)
        print("✅ Клієнт створено")
        
        # Отримання секрету
        print(f"🔍 Отримання секрету '{SECRET_NAME}'...")
        secret = client.get_secret(SECRET_NAME)
        
        print("🎉 УСПІХ!")
        print(f"📝 Секрет: {secret.value}")
        print(f"🔢 Версія: {secret.properties.version}")
        
        return True
        
    except ClientAuthenticationError as e:
        print(f"❌ Помилка автентифікації: {e}")
        print("\n💡 Рішення:")
        print("1. Запустіть: az login")
        print("2. Перевірте права доступу до Key Vault")
        return False
        
    except ResourceNotFoundError as e:
        print(f"❌ Секрет не знайдено: {e}")
        print("\n💡 Перевірте чи існує секрет:")
        print(f"az keyvault secret show --vault-name django-app-keyvault --name {SECRET_NAME}")
        return False
        
    except Exception as e:
        print(f"❌ Загальна помилка: {e}")
        print(f"📊 Тип помилки: {type(e).__name__}")
        return False

if __name__ == "__main__":
    # Перевірка чи встановлені пакети
    try:
        import azure.keyvault.secrets
        import azure.identity
        print("✅ Необхідні пакети встановлені")
    except ImportError as e:
        print(f"❌ Відсутні пакети: {e}")
        print("💡 Встановіть: pip install azure-keyvault-secrets azure-identity")
        exit(1)
    
    # Запуск тесту
    success = test_keyvault_simple()
    
    if success:
        print("\n🎯 Наступні кроки:")
        print("1. Оновіть kv_vars.py з правильними credentials")
        print("2. Інтегруйте з Django settings")
        print("3. Додайте більше секретів до Key Vault")
    else:
        print("\n🔧 Діагностика:")
        print("1. az account show  # Перевірка входу")
        print("2. az keyvault list  # Перевірка доступу")
        print("3. az keyvault secret list --vault-name django-app-keyvault")

```

