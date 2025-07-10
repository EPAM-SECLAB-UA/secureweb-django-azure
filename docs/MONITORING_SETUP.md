
# 📊 Setup Monitoring Script Documentation

## 🎯 Опис

`setup-monitoring.sh` - це автоматизований скрипт для налаштування комплексного моніторингу Azure App Service додатків. Скрипт створює повноцінну систему логування та моніторингу для існуючої Azure інфраструктури.

## 🚀 Призначення

Скрипт призначений для додавання профессійного моніторингу до вже розгорнутих Django додатків на Azure App Service без необхідності пересоздавання інфраструктури.

## 📋 Що робить скрипт

### ✅ Створення та налаштування:
- **Log Analytics Workspace** з оптимізованими настройками
- **Diagnostic Settings** для всіх типів логів App Service
- **Application-level logging** з детальними налаштуваннями
- **Alert Rules** для моніторингу критичних метрик
- **Автоматичне тестування** налаштованого логування

### 📊 Типи логів що збираються:
- **HTTP Access Logs** - всі HTTP запити та відповіді
- **Console Logs** - вивід додатку та системні повідомлення
- **Application Logs** - логи самого Django додатку
- **Audit Logs** - аудит дій користувачів
- **Security Logs** - події безпеки та IP блокування
- **Platform Logs** - системні події Azure платформи
- **Performance Metrics** - CPU, Memory, Response Time

## 🔧 Конфігурація

### 📝 Основні параметри:
```bash
RESOURCE_GROUP="django-app-budget-rg"          # Існуюча resource group
LOCATION="westeurope"                          # Azure регіон
APP_NAME="django-app-budget-1752082786"       # Назва App Service
WORKSPACE_NAME="django-app-custom-monitoring-ws" # Новий Log Analytics workspace
```

### 🏷️ Теги ресурсів:
- `Environment=budget` - тип середовища
- `Project=django-app` - назва проекту
- `CreatedBy=MonitoringScript` - створено скриптом

## 📊 Log Analytics Workspace

### ⚙️ Налаштування:
- **SKU**: PerGB2018 (Pay-as-you-go)
- **Retention**: 30 днів
- **Location**: West Europe
- **Daily Quota**: Необмежено (-1.0 GB)

### 💰 Вартість:
- **Перші 5GB/місяць**: Безкоштовно
- **Понад 5GB**: ~$2.30/GB
- **Очікувана вартість**: $2-5/місяць для типового Django додатку

## 🚨 Alert Rules

### 1. HTTP 5xx Errors Alert
```bash
Name: "django-app-budget-1752082786-http-5xx-errors"
Condition: count > 5 HTTP 5xx errors за 5 хвилин
Severity: 2 (Warning)
Frequency: кожні 5 хвилин
```

### 2. High CPU Usage Alert
```bash
Name: "django-app-budget-1752082786-high-cpu"
Condition: середній CPU > 80%
Severity: 2 (Warning)
Frequency: кожні 5 хвилин
```

## 🛠️ Передумови

### ✅ Вимоги:
1. **Azure CLI** встановлено та налаштовано
2. **Активна Azure сесія** (`az login`)
3. **Існуюча Resource Group**: `django-app-budget-rg`
4. **Існуючий App Service**: `django-app-budget-1752082786`
5. **Права доступу**: Contributor роль на resource group

### 📦 Залежності:
- Azure CLI 2.0+
- Bash shell
- curl (для тестування)
- timeout command

## 🚀 Використання

### 1. Завантаження та підготовка:
```bash
# Завантажте скрипт
curl -O https://raw.githubusercontent.com/your-repo/setup-monitoring.sh

# Зробіть виконуваним
chmod +x setup-monitoring.sh
```

### 2. Запуск:
```bash
# Простий запуск
./setup-monitoring.sh

# Запуск з логуванням
./setup-monitoring.sh 2>&1 | tee monitoring-setup.log
```

### 3. Перевірка результату:
```bash
# Перевірка створених ресурсів
az monitor log-analytics workspace list --resource-group django-app-budget-rg --output table

# Перевірка diagnostic settings
az monitor diagnostic-settings list \
  --resource "/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786" \
  --output table
```

## 📈 Функції скрипта

### 🔍 validate_prerequisites()
Перевіряє наявність всіх необхідних компонентів та доступу:
- Azure CLI встановлення
- Активна Azure сесія
- Існування Resource Group та App Service
- Отримання Subscription ID

### 🏗️ create_log_analytics_workspace()
Створює новий Log Analytics workspace з оптимізованими налаштуваннями:
- Перевіряє існування workspace
- Створює з budget-friendly конфігурацією
- Встановлює відповідні теги

### ⚙️ setup_diagnostic_settings()
Налаштовує збір всіх типів логів:
- Видаляє існуючі settings при потребі
- Створює comprehensive diagnostic configuration
- Вмикає всі категорії логів та метрик

### 📝 configure_app_service_logging()
Налаштовує logging на рівні App Service:
- FileSystem logging на Information рівні
- HTTP logging з 3-денним retention
- Detailed error messages
- Failed request tracing

### 🚨 create_sample_alerts()
Створює базові alert rules:
- HTTP 5xx errors monitoring
- High CPU usage alerts
- Graceful error handling

### 🧪 test_logging()
Тестує налаштоване логування:
- Генерує тестовий HTTP трафік
- Перевіряє real-time log streaming
- Валідує працездатність системи

## 🔍 Результати роботи

### 📊 Створені ресурси:
1. **Log Analytics Workspace**: `django-app-custom-monitoring-ws`
2. **Diagnostic Settings**: `django-app-budget-1752082786-enhanced-diagnostics`
3. **Alert Rules**: 2 базових правила моніторингу
4. **App Service Log Configuration**: повне логування

### 📈 Доступні дані:
- HTTP access logs з IP адресами та статус кодами
- Django application logs з рівнями Error/Warning/Info
- System console output
- Performance metrics (CPU, Memory, Requests)
- Security audit logs

## 🔍 Корисні Kusto запити

### 📊 HTTP логи за останню годину:
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| project TimeGenerated, CsMethod, CsUriStem, ScStatus, CIp
| order by TimeGenerated desc
```

### ⚠️ Помилки додатку:
```kusto
AppServiceConsoleLogs
| where TimeGenerated > ago(1h)
| where Level == "Error"
| project TimeGenerated, Level, ResultDescription
```

### 👥 Топ IP адрес:
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| summarize RequestCount = count() by CIp
| order by RequestCount desc
| take 10
```

### 📈 Performance метрики:
```kusto
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB"
| where MetricName == "CpuPercentage"
| summarize avg(Average) by bin(TimeGenerated, 5m)
| order by TimeGenerated desc
```

### 🔍 Failed requests:
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where ScStatus >= 400
| summarize count() by ScStatus, CsUriStem
| order by count_ desc
```

## 🐛 Troubleshooting

### ❌ Поширені помилки:

#### 1. "Azure CLI не встановлено"
```bash
# Встановіть Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### 2. "Не залогінений в Azure CLI"
```bash
# Увійдіть в Azure
az login
```

#### 3. "Resource Group не знайдено"
```bash
# Перевірте існування resource group
az group list --output table
```

#### 4. "Недостатньо прав доступу"
```bash
# Перевірте ваші ролі
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table
```

### 🔧 Ручне виправлення:

#### Видалення created workspace:
```bash
az monitor log-analytics workspace delete \
  --resource-group django-app-budget-rg \
  --workspace-name django-app-custom-monitoring-ws \
  --yes
```

#### Видалення diagnostic settings:
```bash
az monitor diagnostic-settings delete \
  --resource "/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786" \
  --name "django-app-budget-1752082786-enhanced-diagnostics"
```

## 📚 Додаткові ресурси

### 🔗 Корисні посилання:
- [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [App Service Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Kusto Query Language](https://docs.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

### 📊 Моніторинг Best Practices:
1. Регулярно переглядайте alert rules
2. Оптимізуйте retention policies
3. Використовуйте dashboard для візуалізації
4. Налаштуйте action groups для notifications
5. Періодично аналізуйте cost optimization

## 📝 Примітки

### ⚠️ Важливо:
- Скрипт безпечний для повторного запуску
- Існуючі налаштування оновлюються, а не видаляються
- Всі зміни логуються з timestamps
- Cost optimization налаштований для budget проектів

### 🔄 Підтримка:
- Скрипт сумісний з Azure CLI 2.0+
- Тестований на Ubuntu, macOS, Windows WSL
- Підтримує idempotent виконання
- Graceful error handling з детальними повідомленнями

---

**Автор**: Monitoring Automation Team  
**Версія**: 1.0  
**Дата**: 2025-07-10  
**Ліцензія**: MIT
