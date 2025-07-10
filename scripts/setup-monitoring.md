


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
