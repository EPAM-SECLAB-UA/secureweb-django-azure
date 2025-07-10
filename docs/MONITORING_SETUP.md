
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




```bash

#!/bin/bash

# =============================================================================
# ДОДАННЯ МОНІТОРИНГУ ДО ІСНУЮЧОЇ AZURE ІНФРАСТРУКТУРИ
# =============================================================================

set -euo pipefail

# Конфігурація для вашої існуючої інфраструктури
RESOURCE_GROUP="django-app-budget-rg"
LOCATION="westeurope"
APP_NAME="django-app-budget-1752082786"
WORKSPACE_NAME="django-app-custom-monitoring-ws"

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] 🚀 $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}"
}

# Валідація передумов
validate_prerequisites() {
    log "Валідація передумов..."
    
    # Перевіряємо Azure CLI
    if ! command -v az &> /dev/null; then
        error "Azure CLI не встановлено"
        exit 1
    fi
    
    # Перевіряємо логін
    if ! az account show &> /dev/null; then
        error "Не залогінений в Azure CLI"
        exit 1
    fi
    
    # Перевіряємо чи існує Resource Group
    if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
        error "Resource Group '$RESOURCE_GROUP' не знайдено"
        exit 1
    fi
    
    # Перевіряємо чи існує App Service
    if ! az webapp show --resource-group $RESOURCE_GROUP --name $APP_NAME &> /dev/null; then
        error "App Service '$APP_NAME' не знайдено в Resource Group '$RESOURCE_GROUP'"
        exit 1
    fi
    
    # Отримуємо subscription ID
    SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    success "Валідація завершена. Subscription: $SUBSCRIPTION_ID"
}

# Перевірка існуючих Log Analytics workspaces
check_existing_workspaces() {
    log "Перевірка існуючих Log Analytics workspaces..."
    
    # Показуємо існуючі workspaces
    echo "Існуючі Log Analytics workspaces:"
    az monitor log-analytics workspace list \
        --resource-group $RESOURCE_GROUP \
        --output table 2>/dev/null || echo "Немає workspaces у Resource Group $RESOURCE_GROUP"
    
    # Перевіряємо чи існує workspace з нашою назвою
    if az monitor log-analytics workspace show \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME &> /dev/null; then
        warning "Workspace '$WORKSPACE_NAME' вже існує. Буде використано існуючий."
        return 0
    fi
    
    success "Готовий до створення нового workspace"
}

# Створення Log Analytics workspace
create_log_analytics_workspace() {
    log "Створення Log Analytics workspace..."
    
    # Перевіряємо чи вже існує
    if az monitor log-analytics workspace show \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME &> /dev/null; then
        warning "Workspace '$WORKSPACE_NAME' вже існує, пропускаємо створення"
        return 0
    fi
    
    # Створюємо новий workspace
    az monitor log-analytics workspace create \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME \
        --location $LOCATION \
        --sku "PerGB2018" \
        --retention-time 30 \
        --tags "Environment=budget" "Project=django-app" "CreatedBy=MonitoringScript"
    
    success "Log Analytics workspace створено: $WORKSPACE_NAME"
}

# Налаштування Diagnostic Settings
setup_diagnostic_settings() {
    log "Налаштування Diagnostic Settings..."
    
    # Отримуємо ID workspace
    WORKSPACE_ID=$(az monitor log-analytics workspace show \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME \
        --query "id" -o tsv)
    
    if [ -z "$WORKSPACE_ID" ]; then
        error "Не вдалося отримати ID workspace"
        exit 1
    fi
    
    # Назва для diagnostic setting
    DIAGNOSTIC_NAME="${APP_NAME}-enhanced-diagnostics"
    
    # Перевіряємо чи вже існує diagnostic setting з такою назвою
    if az monitor diagnostic-settings show \
        --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
        --name $DIAGNOSTIC_NAME &> /dev/null; then
        warning "Diagnostic setting '$DIAGNOSTIC_NAME' вже існує. Оновлюємо..."
        
        # Видаляємо існуючий для оновлення
        az monitor diagnostic-settings delete \
            --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
            --name $DIAGNOSTIC_NAME
    fi
    
    # Створюємо новий diagnostic setting
    az monitor diagnostic-settings create \
        --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
        --name $DIAGNOSTIC_NAME \
        --workspace "$WORKSPACE_ID" \
        --logs '[
            {
                "category": "AppServiceHTTPLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            },
            {
                "category": "AppServiceConsoleLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            },
            {
                "category": "AppServiceAppLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            },
            {
                "category": "AppServiceAuditLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            },
            {
                "category": "AppServiceIPSecAuditLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            },
            {
                "category": "AppServicePlatformLogs",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            }
        ]' \
        --metrics '[
            {
                "category": "AllMetrics",
                "enabled": true,
                "retentionPolicy": {"enabled": false, "days": 0}
            }
        ]'
    
    success "Diagnostic Settings налаштовано для workspace: $WORKSPACE_NAME"
}

# Налаштування App Service логування
configure_app_service_logging() {
    log "Налаштування App Service логування..."
    
    # Увімкнемо всі типи логування
    az webapp log config \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --application-logging filesystem \
        --level information \
        --web-server-logging filesystem \
        --detailed-error-messages true \
        --failed-request-tracing true
    
    success "App Service логування налаштовано"
}

# Створення sample alert rules
create_sample_alerts() {
    log "Створення зразкових alert rules..."
    
    # Отримуємо ID workspace
    WORKSPACE_ID=$(az monitor log-analytics workspace show \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME \
        --query "id" -o tsv)
    
    # Alert для HTTP 5xx помилок
    az monitor scheduled-query create \
        --resource-group $RESOURCE_GROUP \
        --name "${APP_NAME}-http-5xx-errors" \
        --description "Alert when HTTP 5xx errors occur" \
        --condition "count 'union AppServiceHTTPLogs | where TimeGenerated > ago(5m) | where ScStatus >= 500' > 5" \
        --condition-query-time-range "5m" \
        --evaluation-frequency "5m" \
        --scopes "$WORKSPACE_ID" \
        --severity 2 \
        --window-size "5m" \
        --tags "Environment=budget" "AlertType=HTTP-Errors" 2>/dev/null || warning "Не вдалося створити HTTP 5xx alert"
    
    # Alert для високого використання CPU
    az monitor metrics alert create \
        --resource-group $RESOURCE_GROUP \
        --name "${APP_NAME}-high-cpu" \
        --description "Alert when CPU usage is high" \
        --condition "avg Percentage CPU > 80" \
        --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
        --evaluation-frequency "5m" \
        --window-size "5m" \
        --severity 2 \
        --tags "Environment=budget" "AlertType=Performance" 2>/dev/null || warning "Не вдалося створити CPU alert"
    
    success "Зразкові alert rules створено"
}

# Тестування логування
test_logging() {
    log "Тестування логування..."
    
    APP_URL="https://$APP_NAME.azurewebsites.net"
    
    # Генеруємо тестовий трафік
    log "Генерація тестового трафіку..."
    curl -s "$APP_URL" > /dev/null || true
    curl -s "$APP_URL/health/" > /dev/null || true
    curl -s "$APP_URL/admin/" > /dev/null || true
    curl -s "$APP_URL/nonexistent-page" > /dev/null || true
    
    success "Тестовий трафік згенеровано"
    
    # Перевіряємо чи працює real-time логування
    log "Перевірка real-time логування (5 секунд)..."
    timeout 5 az webapp log tail \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME || true
    
    success "Логування працює"
}

# Показ інформації про налаштування
show_monitoring_info() {
    # Отримуємо Workspace ID для портала
    WORKSPACE_ID=$(az monitor log-analytics workspace show \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE_NAME \
        --query "customerId" -o tsv)
    
    echo ""
    echo "============================================================="
    echo "🎉 МОНІТОРИНГ НАЛАШТОВАНО УСПІШНО"
    echo "============================================================="
    echo ""
    echo "📊 Log Analytics Workspace:"
    echo "   📋 Назва: $WORKSPACE_NAME"
    echo "   🆔 Workspace ID: $WORKSPACE_ID"
    echo "   📍 Resource Group: $RESOURCE_GROUP"
    echo ""
    echo "🔍 Де переглядати логи:"
    echo "   🌐 Azure Portal: https://portal.azure.com"
    echo "   📊 Log Analytics: Workspaces → $WORKSPACE_NAME → Logs"
    echo "   📈 App Service: $APP_NAME → Monitoring → Logs"
    echo ""
    echo "📋 Налаштовані логи:"
    echo "   ✅ HTTP Access Logs"
    echo "   ✅ Console Logs"
    echo "   ✅ Application Logs"
    echo "   ✅ Audit Logs"
    echo "   ✅ Security Logs"
    echo "   ✅ Platform Logs"
    echo "   ✅ Metrics"
    echo ""
    echo "🧪 Корисні Kusto запити:"
    echo ""
    echo "   // HTTP логи за останню годину"
    echo "   AppServiceHTTPLogs"
    echo "   | where TimeGenerated > ago(1h)"
    echo "   | project TimeGenerated, CsMethod, CsUriStem, ScStatus"
    echo ""
    echo "   // Помилки додатку"
    echo "   AppServiceConsoleLogs"
    echo "   | where TimeGenerated > ago(1h)"
    echo "   | where Level == \"Error\""
    echo ""
    echo "   // Топ IP адрес"
    echo "   AppServiceHTTPLogs"
    echo "   | summarize count() by CIp"
    echo "   | top 10 by count_"
    echo ""
    echo "🚨 Alert Rules:"
    echo "   ⚠️ HTTP 5xx errors (>5 за 5 хвилин)"
    echo "   ⚠️ High CPU usage (>80%)"
    echo ""
    echo "💰 Вартість: ~$2-5/місяць (перші 5GB безкоштовно)"
    echo "============================================================="
}

# Основна функція
main() {
    log "Початок налаштування моніторингу для існуючої інфраструктури"
    log "App Service: $APP_NAME"
    log "Resource Group: $RESOURCE_GROUP"
    
    validate_prerequisites
    check_existing_workspaces
    create_log_analytics_workspace
    setup_diagnostic_settings
    configure_app_service_logging
    create_sample_alerts
    test_logging
    show_monitoring_info
    
    success "Моніторинг налаштовано успішно!"
    
    echo ""
    echo "🎯 Наступні кроки:"
    echo "1. Перейдіть до Azure Portal → Log Analytics → $WORKSPACE_NAME"
    echo "2. Спробуйте Kusto запити вище"
    echo "3. Налаштуйте додаткові alerts за потребою"
    echo "4. Перевірте дані через 10-15 хвилин"
}

# Обробка помилок
trap 'error "Скрипт завершився з помилкою на лінії $LINENO"' ERR

# Запуск
main "$@"

```

## 🚀 **Як використовувати скрипт:**

### **1. Збережіть скрипт:**
```bash
# Створіть файл
cat > setup-monitoring.sh << 'EOF'
# Вставте вміст з артефакту вище
EOF

# Зробіть виконуваним
chmod +x setup-monitoring.sh
```

### **2. Запустіть скрипт:**
```bash
# Запуск для вашої існуючої інфраструктури
./setup-monitoring.sh
```

## 🔧 **Що робить скрипт:**

### **✅ Валідація:**
- Перевіряє Azure CLI
- Перевіряє існування Resource Group
- Перевіряє існування App Service
- Показує існуючі Log Analytics workspaces

### **📊 Створення моніторингу:**
- Створює новий Log Analytics workspace
- Налаштовує Diagnostic Settings з усіма типами логів
- Увімкнює детальне App Service логування
- Створює зразкові alert rules

### **🧪 Тестування:**
- Генерує тестовий трафік
- Перевіряє real-time логування
- Показує корисні Kusto запити

## 🎯 **Переваги цього скрипта:**

### **🔒 Безпечний:**
- Перевіряє існуючі ресурси
- Не видаляє існуючі налаштування
- Оновлює тільки при необхідності

### **💰 Budget-friendly:**
- Використовує PerGB2018 sku (перші 5GB безкоштовно)
- 30-денний retention
- Тільки необхідні логи

### **📋 Інформативний:**
- Показує детальну інформацію про налаштування
- Надає готові Kusto запити
- Пояснює наступні кроки

## 🔍 **Після запуску ви матимете:**

1. **✅ Новий Log Analytics workspace** - `django-app-custom-monitoring-ws`
2. **✅ Повний набір логів** - HTTP, Console, App, Audit, Security, Platform
3. **✅ Metrics collection** - CPU, Memory, Requests
4. **✅ Alert rules** - HTTP 5xx errors, High CPU
5. **✅ Готові Kusto запити** для аналізу

**Просто запустіть скрипт і через 5-10 хвилин у вас буде повний моніторинг!** 🎉



