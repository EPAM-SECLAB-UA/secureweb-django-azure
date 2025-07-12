
Я створив повну лекцію на основі наданого відео. Лекція структурована як академічний матеріал з:

## 🎯 **Основні розділи:**

1. **Проблематика** - чому не можна зберігати секрети в коді
2. **Теоретична частина** - що таке Azure Key Vault та Service Principal
3. **Практична частина** - покроковий код з поясненнями
4. **Django інтеграція** - різні способи впровадження
5. **Best practices** - професійні рекомендації

## 📚 **Педагогічні елементи:**

- ✅ Чіткі приклади коду з коментарями
- ✅ Пояснення кожного кроку
- ✅ Практичні завдання для закріплення
- ✅ Контрольні питання
- ✅ Візуальні акценти (емодзі, виділення)
- ✅ Посилання на додаткові ресурси

## 🎓 **Для студентів:**

Лекція підходить як для початківців (пояснює базові концепції), так і для досвідчених розробників (advanced практики та інтеграція).

Матеріал можна використовувати як:
- 📖 Самостійне вивчення
- 🎥 Основа для відео-лекції  
- 📋 Методичка для викладача
- 💻 Практичний гайд для розробників

Хочете, щоб я додав якісь конкретні розділи або змінив акценти в лекції?


-------------------------------------------------------------------------------------------------------------------------------------

# 🔐 Лекція: Отримання секретів з Azure Key Vault у Python додатках

## 📚 Тема лекції
**Безпечне управління секретами у Django додатках за допомогою Azure Key Vault**

---

## 🎯 Мета лекції

Навчитись безпечно отримувати та використовувати секрети (паролі, API ключі, токени) у Python/Django додатках за допомогою Azure Key Vault замість зберігання їх у вихідному коді.

---

## 📋 План лекції

1. [Проблема зберігання секретів](#проблема-зберігання-секретів)
2. [Що таке Azure Key Vault](#що-таке-azure-key-vault)
3. [Налаштування автентифікації](#налаштування-автентифікації)
4. [Практична реалізація](#практична-реалізація)
5. [Інтеграція з Django](#інтеграція-з-django)
6. [Найкращі практики](#найкращі-практики)

---

## ⚠️ Проблема зберігання секретів

### Чого НЕ робити:
```python
# ❌ НЕПРАВИЛЬНО - секрети у коді
SECRET_KEY = "django-insecure-h4rd-c0d3d-k3y"
DATABASE_PASSWORD = "mypassword123"
API_KEY = "sk_live_abcd1234efgh5678"

# ❌ НЕПРАВИЛЬНО - секрети у Git
# settings.py
DEBUG = True
SECRET_KEY = "real-production-key"  # Це потрапить у Git!
```

### Проблеми такого підходу:
- 🚨 **Витік секретів** через систему контролю версій
- 👀 **Доступ всім розробникам** до production секретів  
- 🔄 **Складність ротації** секретів
- 📝 **Відсутність аудиту** доступу до секретів
- 🏢 **Порушення корпоративної безпеки**

---

## 🔐 Що таке Azure Key Vault

### Визначення:
**Azure Key Vault** - це хмарний сервіс для безпечного зберігання та управління:
- 🔑 **Секретами** (паролі, connection strings, API ключі)
- 🔐 **Ключами шифрування** 
- 📜 **Сертифікатами**

### Переваги використання:
- ✅ **Централізоване управління** секретами
- ✅ **Контроль доступу** через AAD (Azure Active Directory)
- ✅ **Аудит та логування** всіх операцій
- ✅ **Автоматична ротація** секретів
- ✅ **Відсутність секретів у коді** додатка

---

## 🔧 Налаштування автентифікації

### Крок 1: Створення Service Principal

Service Principal - це "ідентичність додатка" у Azure, яка дозволяє додатку автентифікуватись та отримувати доступ до ресурсів.

```bash
# Створення Service Principal
az ad sp create-for-rbac --name "django-app-keyvault-access"

# Результат:
{
  "appId": "12345678-1234-1234-1234-123456789abc",      # Application ID
  "password": "abcdef123456",                           # Client Secret (Key)
  "tenant": "87654321-4321-4321-4321-210987654321"     # Tenant ID
}
```

### Крок 2: Налаштування змінних оточення

```python
# kv_vars.py - НІКОЛИ НЕ КОМІТЬСЯ У GIT!
import os

# Azure AD Authentication
AZURE_CLIENT_ID = "12345678-1234-1234-1234-123456789abc"      # Application ID
AZURE_CLIENT_SECRET = "abcdef123456"                          # Key/Token
AZURE_TENANT_ID = "87654321-4321-4321-4321-210987654321"     # Tenant ID

# Key Vault Configuration  
AZURE_KEY_VAULT_URL = "https://my-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"
SECRET_VERSION = "1.0"  # Опціонально, якщо порожньо - береться остання версія
```

### ⚠️ Важливо про kv_vars.py:
- 🚫 **НІКОЛИ не коміться у Git**
- 🔒 **Зберігайте безпечно** - обмежений доступ
- 🔄 **Використовуйте змінні середовища** у production
- 🛡️ **Якщо файл скомпрометовано** - негайно змініть секрети

---

## 💻 Практична реалізація

### Крок 1: Встановлення пакету

```bash
pip install azure-keyvault-secrets
```

### Крок 2: Базовий код для отримання секрету

```python
# kv.py
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
import kv_vars  # Файл з змінними

# Крок 1: Створення credentials для автентифікації
credentials = ClientSecretCredential(
    client_id=kv_vars.AZURE_CLIENT_ID,        # Application ID
    client_secret=kv_vars.AZURE_CLIENT_SECRET, # Key
    tenant_id=kv_vars.AZURE_TENANT_ID         # Tenant ID
)

# Крок 2: Створення клієнта Key Vault
client = SecretClient(
    vault_url=kv_vars.AZURE_KEY_VAULT_URL,
    credential=credentials
)

# Крок 3: Отримання секрету
secret = client.get_secret(
    name=kv_vars.SECRET_NAME,
    version=kv_vars.SECRET_VERSION  # Опціонально
)

# Крок 4: Використання значення секрету
password = secret.value
print(f"Отримано пароль: {password}")
```

### Крок 3: Пояснення процесу

```python
# Повний об'єкт секрету містить багато метаданих:
{
  "id": "https://vault.vault.azure.net/secrets/db-password/1.0",
  "name": "database-password", 
  "properties": {
    "created_on": "2024-01-15T10:30:00Z",
    "updated_on": "2024-01-15T10:30:00Z",
    "enabled": true,
    "version": "1.0"
  },
  "value": "SuperSecretPassword123!"  # ← Нас цікавить тільки це
}

# Тому використовуємо .value для отримання самого секрету
password = secret.value  # "SuperSecretPassword123!"
```

---

## 🐍 Інтеграція з Django

### Варіант 1: Простий підхід

```python
# config/keyvault.py
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from decouple import config

def get_keyvault_secret(secret_name, version=None):
    """Отримання секрету з Azure Key Vault"""
    
    # Credentials з змінних середовища
    credentials = ClientSecretCredential(
        client_id=config('AZURE_CLIENT_ID'),
        client_secret=config('AZURE_CLIENT_SECRET'),
        tenant_id=config('AZURE_TENANT_ID')
    )
    
    # Key Vault клієнт
    client = SecretClient(
        vault_url=config('AZURE_KEY_VAULT_URL'),
        credential=credentials
    )
    
    # Отримання секрету
    secret = client.get_secret(name=secret_name, version=version)
    return secret.value

# config/settings.py
from .keyvault import get_keyvault_secret

# Використання секретів з Key Vault
SECRET_KEY = get_keyvault_secret('django-secret-key')
DATABASE_PASSWORD = get_keyvault_secret('database-password')
EMAIL_HOST_PASSWORD = get_keyvault_secret('email-password')
STRIPE_SECRET_KEY = get_keyvault_secret('stripe-api-key')
```

### Варіант 2: Пакетне отримання секретів

```python
# config/keyvault.py
def get_multiple_secrets(secret_names):
    """Отримання кількох секретів одночасно"""
    
    # Ініціалізація клієнта (один раз)
    credentials = ClientSecretCredential(
        client_id=config('AZURE_CLIENT_ID'),
        client_secret=config('AZURE_CLIENT_SECRET'),
        tenant_id=config('AZURE_TENANT_ID')
    )
    
    client = SecretClient(
        vault_url=config('AZURE_KEY_VAULT_URL'),
        credential=credentials
    )
    
    # Отримання всіх секретів
    secrets = {}
    for secret_name in secret_names:
        try:
            secret = client.get_secret(secret_name)
            secrets[secret_name] = secret.value
        except Exception as e:
            print(f"Помилка отримання {secret_name}: {e}")
            secrets[secret_name] = None
    
    return secrets

# config/settings.py
# Список необхідних секретів
required_secrets = [
    'django-secret-key',
    'database-password', 
    'email-password',
    'stripe-api-key',
    'sendgrid-api-key'
]

# Отримання всіх секретів одночасно
secrets = get_multiple_secrets(required_secrets)

# Використання секретів
SECRET_KEY = secrets['django-secret-key']
DATABASE_PASSWORD = secrets['database-password']
EMAIL_HOST_PASSWORD = secrets['email-password']
```

### Варіант 3: Ініціалізація при запуску додатка

```python
# config/apps.py
from django.apps import AppConfig
from .keyvault import get_multiple_secrets

class ConfigConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'config'
    
    def ready(self):
        """Виконується при запуску Django"""
        # Отримання секретів при запуску
        secrets = get_multiple_secrets([
            'django-secret-key',
            'database-password',
            'api-keys'
        ])
        
        # Збереження у глобальних змінних або кеші
        import django.conf
        django.conf.settings.SECRETS = secrets
```

---

## 📍 Місця розміщення коду отримання секретів

### 1. **settings.py** (найпростіший)
```python
# config/settings.py - секрети отримуються при імпорті
SECRET_KEY = get_keyvault_secret('django-secret-key')
```

### 2. **manage.py** (при запуску команд)
```python
# manage.py - секрети отримуються перед будь-якою командою
if __name__ == '__main__':
    # Ініціалізація секретів
    initialize_secrets()
    # Запуск Django
    execute_from_command_line(sys.argv)
```

### 3. **wsgi.py** (для production серверів)
```python
# config/wsgi.py - секрети отримуються при запуску WSGI
import os
from django.core.wsgi import get_wsgi_application
from .keyvault import initialize_secrets

# Ініціалізація секретів перед запуском
initialize_secrets()

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_wsgi_application()
```

### 4. **apps.py** (в AppConfig.ready())
```python
# apps/core/apps.py - секрети отримуються при ініціалізації додатка
class CoreConfig(AppConfig):
    def ready(self):
        from config.keyvault import initialize_secrets
        initialize_secrets()
```

---

## 🔄 Версіювання секретів

### Чому важливо:
- 📅 **Поетапне оновлення** - не всі додатки оновлюються одночасно
- 🔙 **Rollback можливості** - повернення до попередньої версії
- 🧪 **Тестування нових секретів** - перед production

### Приклади використання:

```python
# Отримання конкретної версії
old_password = client.get_secret("database-password", version="1.0")
new_password = client.get_secret("database-password", version="2.0")

# Отримання останньої версії (за замовчуванням)
latest_password = client.get_secret("database-password")  # version=None
```

### Аналогія з Docker:
```bash
# Docker без тега = остання версія  
docker pull nginx

# Docker з конкретним тегом
docker pull nginx:1.20

# Key Vault працює аналогічно:
# Без версії = остання версія
# З версією = конкретна версія
```

---

## 🚀 Найкращі практики

### 1. **Безпека файлів конфігурації**
```python
# ✅ ПРАВИЛЬНО - використання .env файлів
# .env (НЕ коміториться)
AZURE_CLIENT_ID=12345678-1234-1234-1234-123456789abc
AZURE_CLIENT_SECRET=abcdef123456
AZURE_TENANT_ID=87654321-4321-4321-4321-210987654321

# settings.py
from decouple import config
AZURE_CLIENT_ID = config('AZURE_CLIENT_ID')
```

### 2. **Обробка помилок**
```python
def get_secret_safe(secret_name, default=None):
    """Безпечне отримання секрету з fallback"""
    try:
        secret = client.get_secret(secret_name)
        return secret.value
    except Exception as e:
        logger.error(f"Помилка отримання секрету {secret_name}: {e}")
        return default

# Використання з fallback
SECRET_KEY = get_secret_safe('django-secret-key', 'fallback-key')
```

### 3. **Кешування секретів**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_cached_secret(secret_name):
    """Кешоване отримання секрету"""
    return client.get_secret(secret_name).value

# Секрет отримається тільки один раз
password = get_cached_secret('database-password')
```

### 4. **Ротація секретів**
```python
def rotate_secret(secret_name, new_value):
    """Ротація секрету з новою версією"""
    client.set_secret(secret_name, new_value)
    print(f"Секрет {secret_name} оновлено")

# Приклад ротації
new_password = generate_strong_password()
rotate_secret('database-password', new_password)
```

---

## 🔍 Практичні завдання

### Завдання 1: Базове отримання секрету
Створіть Python скрипт, який отримує секрет з Key Vault та виводить його значення.

### Завдання 2: Django інтеграція  
Інтегруйте Key Vault у Django проект для отримання SECRET_KEY та DATABASE_PASSWORD.

### Завдання 3: Обробка помилок
Додайте обробку помилок та fallback значення для випадків, коли Key Vault недоступний.

### Завдання 4: Пакетне отримання
Створіть функцію для отримання кількох секретів одночасно з мінімальною кількістю запитів.

---

## ❓ Контрольні питання

1. **Чому не можна зберігати секрети у вихідному коді?**
2. **Що таке Service Principal та навіщо він потрібен?**
3. **Які три обов'язкові параметри потрібні для автентифікації в Azure?**
4. **Яка різниця між отриманням секрету з версією та без неї?**
5. **У якому місці Django додатка краще отримувати секрети?**
6. **Як забезпечити fallback, якщо Key Vault недоступний?**

---

## 📚 Корисні ресурси

- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure SDK for Python](https://docs.microsoft.com/en-us/python/api/overview/azure/keyvault-secrets-readme)
- [Django Security Best Practices](https://docs.djangoproject.com/en/stable/topics/security/)
- [12-Factor App: Config](https://12factor.net/config)

---

## 🎯 Висновки лекції

1. ✅ **Azure Key Vault** - безпечний спосіб зберігання секретів
2. ✅ **Service Principal** забезпечує автентифікацію додатка
3. ✅ **Версіювання секретів** дозволяє поетапне оновлення
4. ✅ **Інтеграція з Django** можлива на різних рівнях
5. ✅ **Обробка помилок** та **кешування** - важливі аспекти
6. ✅ **Ніколи не коміті секрети** у систему контролю версій

### Наступна лекція: 
**"Managed Identity та автоматизація доступу до Key Vault"** 🚀

-------------------------------------------------------------


Ось детальний гайд де отримати кожне з цих значень:## 🎯 **Короткий підсумок де взяти кожне значення:**

### **1. AZURE_TENANT_ID:**
- 🌐 **Azure Portal:** Azure Active Directory → Overview → Tenant ID
- 💻 **CLI:** `az account show --query tenantId -o tsv`

### **2. AZURE_CLIENT_ID + AZURE_CLIENT_SECRET:**
- 🌐 **Portal:** Azure AD → App registrations → New registration → Overview (Client ID) + Certificates & secrets (Secret)
- 💻 **CLI:** `az ad sp create-for-rbac --name "app-name"` (виведе обидва значення)

### **3. AZURE_KEY_VAULT_URL:**
- 🌐 **Portal:** Key vaults → Create → Overview → Vault URI
- 💻 **CLI:** `az keyvault show --name vault-name --query properties.vaultUri`

### **4. SECRET_NAME + SECRET_VERSION:**
- 🌐 **Portal:** Key Vault → Secrets → Generate/Import (задаєте назву)
- 💻 **CLI:** `az keyvault secret set --vault-name vault --name "secret-name" --value "value"`

## ⚡ **Швидкий старт за 5 хвилин:**

```bash
# 1. Створення всього через CLI
az ad sp create-for-rbac --name "django-keyvault-app"
az keyvault create --name "my-unique-vault-123" --resource-group "my-rg"
az keyvault secret set --vault-name "my-unique-vault-123" --name "test-secret" --value "hello"

# 2. Отримання URL
az keyvault show --name "my-unique-vault-123" --query properties.vaultUri
```

**Головне:** Запам'ятайте AZURE_CLIENT_SECRET одразу - він більше не показується! 🔒

-----------------------------------------------------------------------------------------------


# 🔍 Де отримати Azure Key Vault credentials - покроковий гайд

## 📋 Значення які потрібно отримати:

```python
# kv_vars.py
AZURE_CLIENT_ID = "12345678-1234-1234-1234-123456789abc"      # Application ID
AZURE_CLIENT_SECRET = "abcdef123456"                          # Key/Token  
AZURE_TENANT_ID = "87654321-4321-4321-4321-210987654321"     # Tenant ID
AZURE_KEY_VAULT_URL = "https://my-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"
SECRET_VERSION = "1.0"
```

---

## 🏢 1. AZURE_TENANT_ID - Ідентифікатор орендаря

### Через Azure Portal:
1. Увійдіть в [Azure Portal](https://portal.azure.com)
2. Натисніть на **Azure Active Directory** (або знайдіть через пошук)
3. У лівому меню виберіть **Overview**
4. Знайдіть **Tenant ID** - це ваш AZURE_TENANT_ID

### Через Azure CLI:
```bash
# Показати інформацію про поточний tenant
az account show --query tenantId -o tsv

# Альтернативний спосіб
az account tenant list --query "[0].tenantId" -o tsv
```

### 📍 Що це таке:
**Tenant ID** - унікальний ідентифікатор вашої Azure Active Directory організації. Всі користувачі та додатки належать до цього tenant.

---

## 🔐 2. AZURE_CLIENT_ID + AZURE_CLIENT_SECRET - Service Principal

Ці два значення отримуються при створенні **Service Principal** (додатка).

### Крок 1: Створення App Registration

#### Через Azure Portal:
1. Перейдіть в **Azure Active Directory**
2. Виберіть **App registrations** в лівому меню
3. Натисніть **+ New registration**
4. Заповніть форму:
   ```
   Name: django-app-keyvault
   Supported account types: Accounts in this organizational directory only
   Redirect URI: (залиште порожнім)
   ```
5. Натисніть **Register**

#### Через Azure CLI:
```bash
# Створення Service Principal
az ad sp create-for-rbac \
    --name "django-app-keyvault" \
    --role "Key Vault Secrets User" \
    --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Результат:
{
  "appId": "12345678-1234-1234-1234-123456789abc",      # ← AZURE_CLIENT_ID
  "password": "abcdef123456",                           # ← AZURE_CLIENT_SECRET
  "tenant": "87654321-4321-4321-4321-210987654321"     # ← AZURE_TENANT_ID
}
```

### Крок 2: Отримання AZURE_CLIENT_ID

#### Через Azure Portal:
1. Після створення App Registration
2. На сторінці **Overview** знайдіть **Application (client) ID**
3. Це ваш **AZURE_CLIENT_ID**

#### Через Azure CLI:
```bash
# Показати всі Service Principals
az ad sp list --display-name "django-app-keyvault" --query "[0].appId" -o tsv
```

### Крок 3: Створення AZURE_CLIENT_SECRET

#### Через Azure Portal:
1. В App Registration перейдіть в **Certificates & secrets**
2. Виберіть вкладку **Client secrets**
3. Натисніть **+ New client secret**
4. Заповніть:
   ```
   Description: Django App Key Vault Access
   Expires: 24 months (рекомендується)
   ```
5. Натисніть **Add**
6. **🚨 ВАЖЛИВО:** Скопіюйте **Value** одразу - він більше не буде показаний!

#### Через Azure CLI:
```bash
# Створення client secret
az ad app credential reset \
    --id YOUR_APP_ID \
    --display-name "Django Key Vault Secret"

# Результат містить password - це ваш AZURE_CLIENT_SECRET
```

---

## 🔑 3. AZURE_KEY_VAULT_URL - URL Key Vault

### Крок 1: Створення Key Vault

#### Через Azure Portal:
1. Перейдіть в **Key vaults** (або знайдіть через пошук)
2. Натисніть **+ Create**
3. Заповніть форму:
   ```
   Resource group: django-app-rg
   Key vault name: django-app-keyvault (має бути унікальним)
   Region: West Europe
   Pricing tier: Standard
   ```
4. Натисніть **Review + create** → **Create**

#### Через Azure CLI:
```bash
# Створення Resource Group
az group create --name django-app-rg --location westeurope

# Створення Key Vault
az keyvault create \
    --name django-app-keyvault \
    --resource-group django-app-rg \
    --location westeurope
```

### Крок 2: Отримання URL

#### Через Azure Portal:
1. Відкрийте ваш Key Vault
2. На сторінці **Overview** знайдіть **Vault URI**
3. Це ваш **AZURE_KEY_VAULT_URL**
   ```
   https://django-app-keyvault.vault.azure.net/
   ```

#### Через Azure CLI:
```bash
# Отримання URL Key Vault
az keyvault show \
    --name django-app-keyvault \
    --resource-group django-app-rg \
    --query properties.vaultUri -o tsv
```

---

## 🔐 4. Налаштування доступу Service Principal до Key Vault

### Через Azure Portal:
1. Відкрийте ваш Key Vault
2. Перейдіть в **Access policies**
3. Натисніть **+ Create**
4. Виберіть permissions:
   ```
   Secret permissions: Get, List
   ```
5. В **Principal** знайдіть ваш Service Principal за назвою
6. Натисніть **Review + create** → **Create**

### Через Azure CLI:
```bash
# Отримання Object ID Service Principal
OBJECT_ID=$(az ad sp show --id YOUR_CLIENT_ID --query id -o tsv)

# Надання доступу до Key Vault
az keyvault set-policy \
    --name django-app-keyvault \
    --object-id $OBJECT_ID \
    --secret-permissions get list
```

---

## 📝 5. SECRET_NAME + SECRET_VERSION - Назва та версія секрету

### Крок 1: Додавання секрету

#### Через Azure Portal:
1. Відкрийте Key Vault
2. Перейдіть в **Secrets**
3. Натисніть **+ Generate/Import**
4. Заповніть:
   ```
   Upload options: Manual
   Name: database-password          ← SECRET_NAME
   Value: MySecretPassword123
   ```
5. Натисніть **Create**

#### Через Azure CLI:
```bash
# Додавання секрету
az keyvault secret set \
    --vault-name django-app-keyvault \
    --name "database-password" \
    --value "MySecretPassword123"
```

### Крок 2: Отримання версії (опціонально)

#### Через Azure Portal:
1. Відкрийте секрет в Key Vault
2. Натисніть на поточну версію
3. Скопіюйте **Version** з URL або деталей

#### Через Azure CLI:
```bash
# Показати всі версії секрету
az keyvault secret list-versions \
    --vault-name django-app-keyvault \
    --name database-password \
    --query "[0].id"

# Результат: https://vault.vault.azure.net/secrets/database-password/abc123def456
# Версія: abc123def456
```

### 📝 Про SECRET_VERSION:
- Якщо **не вказувати версію** - буде отримана остання версія
- Якщо **вказати версію** - буде отримана конкретна версія
- **Рекомендація:** Не вказувати для простоти (завжди остання версія)

---

## 🔍 Повний приклад отримання всіх значень через Azure CLI

```bash
#!/bin/bash

# Змінні
RESOURCE_GROUP="django-app-rg"
KEY_VAULT_NAME="django-app-keyvault"
APP_NAME="django-app-keyvault"

echo "🚀 Створення повної конфігурації Azure Key Vault..."

# 1. Створення Resource Group
az group create --name $RESOURCE_GROUP --location westeurope

# 2. Створення Key Vault
az keyvault create \
    --name $KEY_VAULT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location westeurope

# 3. Створення Service Principal
SP_RESULT=$(az ad sp create-for-rbac --name $APP_NAME --skip-assignment)

# 4. Отримання значень
CLIENT_ID=$(echo $SP_RESULT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_RESULT | jq -r '.password')  
TENANT_ID=$(echo $SP_RESULT | jq -r '.tenant')
VAULT_URL=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query properties.vaultUri -o tsv)

# 5. Налаштування доступу
OBJECT_ID=$(az ad sp show --id $CLIENT_ID --query id -o tsv)
az keyvault set-policy \
    --name $KEY_VAULT_NAME \
    --object-id $OBJECT_ID \
    --secret-permissions get list

# 6. Додавання тестового секрету
az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "database-password" \
    --value "MySecretPassword123"

# 7. Виведення результатів
echo "✅ Конфігурація створена!"
echo ""
echo "📝 Додайте ці значення у ваш kv_vars.py:"
echo ""
echo "AZURE_CLIENT_ID = \"$CLIENT_ID\""
echo "AZURE_CLIENT_SECRET = \"$CLIENT_SECRET\""
echo "AZURE_TENANT_ID = \"$TENANT_ID\""
echo "AZURE_KEY_VAULT_URL = \"$VAULT_URL\""
echo "SECRET_NAME = \"database-password\""
echo "SECRET_VERSION = \"\"  # Остання версія"
echo ""
echo "🔒 ВАЖЛИВО: Не коміть CLIENT_SECRET у Git!"
```

---

## 🔒 Безпека та рекомендації

### ❌ Чого НЕ робити:
```bash
# НЕ коміть у Git
git add kv_vars.py  # ❌ НЕБЕЗПЕЧНО!

# НЕ показуйте у логах
print(f"Secret: {AZURE_CLIENT_SECRET}")  # ❌ НЕБЕЗПЕЧНО!

# НЕ зберігайте у plain text файлах
echo "secret=abc123" > secrets.txt  # ❌ НЕБЕЗПЕЧНО!
```

### ✅ Що робити ПРАВИЛЬНО:
```bash
# Додайте у .gitignore
echo "kv_vars.py" >> .gitignore
echo "*.secret" >> .gitignore
echo ".env" >> .gitignore

# Використовуйте змінні середовища
export AZURE_CLIENT_SECRET="abc123"

# Використовуйте .env файли (не коміт у Git)
echo "AZURE_CLIENT_SECRET=abc123" > .env
```

### 🔄 Ротація секретів:
```bash
# Регулярно міняйте Client Secret (кожні 6-12 місяців)
az ad app credential reset --id YOUR_APP_ID

# Видаляйте старі секрети
az ad app credential delete --id YOUR_APP_ID --key-id OLD_KEY_ID
```

---

## 🎯 Швидкий чеклист

- [ ] **AZURE_TENANT_ID** - з Azure AD → Overview
- [ ] **AZURE_CLIENT_ID** - з App Registration → Overview  
- [ ] **AZURE_CLIENT_SECRET** - з App Registration → Certificates & secrets
- [ ] **AZURE_KEY_VAULT_URL** - з Key Vault → Overview → Vault URI
- [ ] **SECRET_NAME** - назва секрету в Key Vault
- [ ] **SECRET_VERSION** - версія секрету (опціонально)
- [ ] **Права доступу** - Service Principal має доступ до Key Vault
- [ ] **.gitignore** - kv_vars.py додано в .gitignore
- [ ] **Тестування** - перевірено отримання секрету

---

## 🆘 Troubleshooting

### Помилка: "Subscription not found"
```bash
# Перевірте активну підписку
az account show

# Встановіть правильну підписку
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Помилка: "Access denied to Key Vault"
```bash
# Перевірте права доступу
az keyvault show --name YOUR_VAULT_NAME --resource-group YOUR_RG

# Додайте права доступу
az keyvault set-policy --name YOUR_VAULT_NAME --object-id YOUR_OBJECT_ID --secret-permissions get list
```

### Помилка: "Key Vault name not available"
```bash
# Key Vault назви мають бути глобально унікальними
# Додайте унікальний суфікс
KEY_VAULT_NAME="django-app-kv-$(date +%s)"
```

Тепер у вас є всі необхідні значення для роботи з Azure Key Vault! 🎉

------------------------------------------------------------------------------------------------------------------------------





------------------------------------------------------------------------------------------------
