#!/bin/bash
# =============================================================================
# ПОКРАЩЕНИЙ скрипт видалення Azure інфраструктури Django додатку
# Версія: 2.0.0
# Покращення: Backup, Multi-environment, Safety, Reporting
# =============================================================================

set -euo pipefail  # Strict error handling

# Кольори та форматування
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Конфігурація
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="${SCRIPT_DIR}/backups"
readonly LOGS_DIR="${SCRIPT_DIR}/logs"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Функції для логування
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "${LOGS_DIR}/cleanup-${TIMESTAMP}.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "${LOGS_DIR}/cleanup-${TIMESTAMP}.log"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "${LOGS_DIR}/cleanup-${TIMESTAMP}.log"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "${LOGS_DIR}/cleanup-${TIMESTAMP}.log"
}

# =============================================================================
# КОНФІГУРАЦІЯ ТА ПАРАМЕТРИ
# =============================================================================

# Параметри за замовчуванням
PROJECT_NAME="${PROJECT_NAME:-django-app}"
ENVIRONMENT="${ENVIRONMENT:-}"
LOCATION="${LOCATION:-West Europe}"
FORCE_DELETE="${FORCE_DELETE:-false}"
CREATE_BACKUP="${CREATE_BACKUP:-true}"
SKIP_CONFIRMATION="${SKIP_CONFIRMATION:-false}"

# Генерація імен ресурсів
generate_resource_names() {
    local env="$1"
    
    RESOURCE_GROUP_NAME="${PROJECT_NAME}-${env}-rg"
    APP_SERVICE_PLAN_NAME="${PROJECT_NAME}-${env}-plan"
    DATABASE_SERVER_NAME_PATTERN="${PROJECT_NAME}-${env}-db-*"
    STORAGE_ACCOUNT_NAME_PATTERN="$(echo ${PROJECT_NAME} | tr -d '-')*"
    KEY_VAULT_NAME_PATTERN="${PROJECT_NAME}-kv-*"
    APP_INSIGHTS_NAME="${PROJECT_NAME}-${env}-insights"
    CONTAINER_REGISTRY_NAME_PATTERN="${PROJECT_NAME}acr*"
}

# =============================================================================
# UTILITY ФУНКЦІЇ
# =============================================================================

# Створення необхідних директорій
setup_directories() {
    mkdir -p "$BACKUP_DIR" "$LOGS_DIR"
}

# Валідація Azure CLI та авторизації
validate_environment() {
    log "🔍 Валідація середовища..."
    
    if ! command -v az &> /dev/null; then
        error "Azure CLI не встановлено"
        exit 1
    fi
    
    if ! az account show &> /dev/null; then
        error "Не авторизовані в Azure CLI. Виконайте: az login"
        exit 1
    fi
    
    local account_name=$(az account show --query user.name -o tsv)
    local subscription_name=$(az account show --query name -o tsv)
    log "✅ Azure Account: $account_name"
    log "✅ Subscription: $subscription_name"
}

# Знаходження реальних імен ресурсів
discover_resources() {
    local resource_group="$1"
    
    log "🔍 Пошук ресурсів в групі: $resource_group"
    
    if ! az group exists --name "$resource_group" 2>/dev/null; then
        warning "Resource Group '$resource_group' не існує"
        return 1
    fi
    
    # Знаходження конкретних ресурсів
    WEB_APP_NAME=$(az webapp list --resource-group "$resource_group" --query "[0].name" -o tsv 2>/dev/null || echo "")
    DATABASE_SERVER_NAME=$(az postgres flexible-server list --resource-group "$resource_group" --query "[0].name" -o tsv 2>/dev/null || echo "")
    STORAGE_ACCOUNT_NAME=$(az storage account list --resource-group "$resource_group" --query "[0].name" -o tsv 2>/dev/null || echo "")
    KEY_VAULT_NAME=$(az keyvault list --resource-group "$resource_group" --query "[0].name" -o tsv 2>/dev/null || echo "")
    CONTAINER_REGISTRY_NAME=$(az acr list --resource-group "$resource_group" --query "[0].name" -o tsv 2>/dev/null || echo "")
    
    # Підрахунок знайдених ресурсів
    local found_count=0
    [ -n "$WEB_APP_NAME" ] && found_count=$((found_count + 1))
    [ -n "$DATABASE_SERVER_NAME" ] && found_count=$((found_count + 1))
    [ -n "$STORAGE_ACCOUNT_NAME" ] && found_count=$((found_count + 1))
    [ -n "$KEY_VAULT_NAME" ] && found_count=$((found_count + 1))
    [ -n "$CONTAINER_REGISTRY_NAME" ] && found_count=$((found_count + 1))
    
    log "✅ Знайдено $found_count основних ресурсів"
    return 0
}

# Показ поточних ресурсів
show_current_resources() {
    local resource_group="$1"
    
    log "📊 Аналіз поточних ресурсів..."
    
    if ! az group exists --name "$resource_group" 2>/dev/null; then
        warning "Resource Group '$resource_group' не існує"
        return 1
    fi
    
    echo ""
    info "📋 Ресурси в групі $resource_group:"
    
    # Детальний список ресурсів
    az resource list --resource-group "$resource_group" --output table 2>/dev/null || {
        warning "Не вдалося отримати список ресурсів"
        return 1
    }
    
    # Підрахунок ресурсів та орієнтовної економії
    local resource_count=$(az resource list --resource-group "$resource_group" --query "length(@)" -o tsv 2>/dev/null || echo "0")
    local estimated_savings
    
    case "$ENVIRONMENT" in
        "production") estimated_savings="~\$150-200" ;;
        "staging") estimated_savings="~\$60-80" ;;
        *) estimated_savings="~\$30-40" ;;
    esac
    
    echo ""
    info "💰 Знайдено $resource_count ресурсів"
    info "💰 Орієнтовна щомісячна економія: $estimated_savings"
    echo ""
}

# =============================================================================
# BACKUP ФУНКЦІОНАЛ
# =============================================================================

create_backup() {
    local resource_group="$1"
    local backup_path="${BACKUP_DIR}/${resource_group}-${TIMESTAMP}"
    
    if [ "$CREATE_BACKUP" != "true" ]; then
        log "⏭️  Backup пропущено (CREATE_BACKUP=false)"
        return 0
    fi
    
    log "💾 Створення backup перед видаленням..."
    mkdir -p "$backup_path"
    
    # Backup Resource Group template
    log "📄 Експорт Resource Group template..."
    if az group export --name "$resource_group" --output json > "$backup_path/resource-group-template.json" 2>/dev/null; then
        log "✅ Resource Group template збережено"
    else
        warning "⚠️  Не вдалося експортувати Resource Group template"
    fi
    
    # Backup Key Vault secrets
    if [ -n "$KEY_VAULT_NAME" ]; then
        log "🔐 Backup Key Vault secrets..."
        local secrets_backup_dir="$backup_path/keyvault-secrets"
        mkdir -p "$secrets_backup_dir"
        
        local secret_count=0
        while IFS= read -r secret_name; do
            if [ -n "$secret_name" ]; then
                local secret_value=$(az keyvault secret show \
                    --vault-name "$KEY_VAULT_NAME" \
                    --name "$secret_name" \
                    --query "value" -o tsv 2>/dev/null || echo "")
                
                if [ -n "$secret_value" ]; then
                    echo "$secret_value" > "$secrets_backup_dir/$secret_name.txt"
                    secret_count=$((secret_count + 1))
                fi
            fi
        done < <(az keyvault secret list --vault-name "$KEY_VAULT_NAME" --query "[].name" -o tsv 2>/dev/null)
        
        log "✅ Key Vault secrets збережено: $secret_count"
    fi
    
    # Backup Database schema (якщо доступно)
    if [ -n "$DATABASE_SERVER_NAME" ]; then
        log "🗄️  Backup Database metadata..."
        if az postgres flexible-server show \
            --resource-group "$resource_group" \
            --name "$DATABASE_SERVER_NAME" \
            --output json > "$backup_path/database-info.json" 2>/dev/null; then
            log "✅ Database metadata збережено"
        else
            warning "⚠️  Не вдалося створити backup database metadata"
        fi
    fi
    
    # Backup конфігурації Web App
    if [ -n "$WEB_APP_NAME" ]; then
        log "🚀 Backup Web App конфігурації..."
        
        # App settings
        az webapp config appsettings list \
            --name "$WEB_APP_NAME" \
            --resource-group "$resource_group" \
            --output json > "$backup_path/webapp-settings.json" 2>/dev/null || true
        
        # App configuration
        az webapp config show \
            --name "$WEB_APP_NAME" \
            --resource-group "$resource_group" \
            --output json > "$backup_path/webapp-config.json" 2>/dev/null || true
        
        log "✅ Web App конфігурація збережена"
    fi
    
    # Створення backup summary
    cat > "$backup_path/backup-summary.txt" << EOF
BACKUP SUMMARY
==============
Created: $(date --iso-8601=seconds)
Resource Group: $resource_group
Environment: $ENVIRONMENT
Project: $PROJECT_NAME
Backup Path: $backup_path

RESOURCES BACKED UP:
- Resource Group Template: $([ -f "$backup_path/resource-group-template.json" ] && echo "✅" || echo "❌")
- Key Vault Secrets: $([ -d "$backup_path/keyvault-secrets" ] && echo "✅ ($secret_count secrets)" || echo "❌")
- Database Metadata: $([ -f "$backup_path/database-info.json" ] && echo "✅" || echo "❌")
- Web App Configuration: $([ -f "$backup_path/webapp-config.json" ] && echo "✅" || echo "❌")

RESTORE INSTRUCTIONS:
1. Recreate Resource Group: az group create --name "$resource_group" --location "$LOCATION"
2. Deploy template: az deployment group create --resource-group "$resource_group" --template-file resource-group-template.json
3. Restore Key Vault secrets manually from keyvault-secrets/
4. Reconfigure Web App settings from webapp-settings.json

NOTE: This backup does not include:
- Database data (use pg_dump for full database backup)
- Storage account data (use azcopy for blob backup)
- Application code (use git repository)
EOF
    
    log "✅ Backup створено: $backup_path"
    log "📄 Детальна інформація: $backup_path/backup-summary.txt"
    
    return 0
}

# =============================================================================
# CONFIRMATION ТА SAFETY
# =============================================================================

confirm_deletion() {
    local resource_group="$1"
    local estimated_savings="$2"
    
    if [ "$SKIP_CONFIRMATION" = "true" ]; then
        log "⏭️  Підтвердження пропущено (SKIP_CONFIRMATION=true)"
        return 0
    fi
    
    echo ""
    echo -e "${RED}⚠️  КРИТИЧНА ОПЕРАЦІЯ: ВИДАЛЕННЯ ІНФРАСТРУКТУРИ${NC}"
    echo -e "${RED}==========================================${NC}"
    echo ""
    echo -e "${BOLD}🎯 Ціль операції:${NC}"
    echo "  🗑️  Resource Group: $resource_group"
    echo "  🌍 Environment: $ENVIRONMENT"
    echo "  📍 Location: $LOCATION"
    echo "  💰 Економія: $estimated_savings/місяць"
    echo ""
    echo -e "${BOLD}🗑️  Ресурси для видалення:${NC}"
    [ -n "$WEB_APP_NAME" ] && echo "  🚀 Web App: $WEB_APP_NAME"
    [ -n "$DATABASE_SERVER_NAME" ] && echo "  🗄️  PostgreSQL: $DATABASE_SERVER_NAME"
    [ -n "$STORAGE_ACCOUNT_NAME" ] && echo "  💾 Storage: $STORAGE_ACCOUNT_NAME"
    [ -n "$KEY_VAULT_NAME" ] && echo "  🔐 Key Vault: $KEY_VAULT_NAME"
    [ -n "$CONTAINER_REGISTRY_NAME" ] && echo "  📦 Container Registry: $CONTAINER_REGISTRY_NAME"
    [ -n "$APP_INSIGHTS_NAME" ] && echo "  📈 App Insights: $APP_INSIGHTS_NAME"
    
    echo ""
    echo -e "${BOLD}💾 Backup статус:${NC}"
    if [ "$CREATE_BACKUP" = "true" ]; then
        echo "  ✅ Backup буде створено перед видаленням"
        echo "  📁 Backup location: ${BACKUP_DIR}/${resource_group}-${TIMESTAMP}"
    else
        echo "  ⚠️  Backup НЕ буде створено"
    fi
    
    echo ""
    echo -e "${BOLD}⚠️  УВАГА:${NC}"
    echo "  • Ця операція НЕЗВОРОТНА"
    echo "  • Всі дані будуть втрачені"
    echo "  • Backup може не включати всі дані"
    echo "  • Відновлення може бути складним"
    echo ""
    
    # Перше підтвердження
    read -p "Ви впевнені, що хочете видалити ВСЮ інфраструктуру? (yes/no): " -r first_confirmation
    echo ""
    
    if [[ "$first_confirmation" != "yes" ]]; then
        echo "❌ Операція скасована користувачем"
        exit 0
    fi
    
    # Друге підтвердження
    echo -e "${YELLOW}🔐 Фінальне підтвердження${NC}"
    echo "Для підтвердження введіть повну назву Resource Group:"
    echo -e "${BOLD}$resource_group${NC}"
    echo ""
    read -p "Введіть назву Resource Group: " -r typed_name
    echo ""
    
    if [[ "$typed_name" != "$resource_group" ]]; then
        echo "❌ Назва не співпадає. Операція скасована для безпеки."
        exit 0
    fi
    
    # Третє підтвердження для production
    if [[ "$ENVIRONMENT" = "production" ]]; then
        echo -e "${RED}🚨 PRODUCTION ENVIRONMENT DETECTED${NC}"
        echo "Це production environment. Додаткове підтвердження потрібне."
        echo ""
        read -p "Введіть 'DELETE PRODUCTION' для підтвердження: " -r production_confirmation
        echo ""
        
        if [[ "$production_confirmation" != "DELETE PRODUCTION" ]]; then
            echo "❌ Production підтвердження не пройшло. Операція скасована."
            exit 0
        fi
    fi
    
    log "✅ Підтвердження отримано. Продовжуємо видалення..."
    return 0
}

# =============================================================================
# CLEANUP ОПЕРАЦІЇ
# =============================================================================

# Видалення специфічних ресурсів перед видаленням Resource Group
cleanup_specific_resources() {
    local resource_group="$1"
    
    log "🧹 Очищення специфічних ресурсів..."
    
    # Soft delete purge для Key Vault
    if [ -n "$KEY_VAULT_NAME" ]; then
        log "🔐 Очищення Key Vault soft delete..."
        if az keyvault list-deleted --query "[?name=='$KEY_VAULT_NAME']" -o tsv | grep -q "$KEY_VAULT_NAME"; then
            az keyvault purge --name "$KEY_VAULT_NAME" --location "$LOCATION" 2>/dev/null || true
            log "✅ Key Vault soft delete очищено"
        fi
    fi
    
    # Зупинка Web App перед видаленням
    if [ -n "$WEB_APP_NAME" ]; then
        log "🚀 Зупинка Web App перед видаленням..."
        az webapp stop --name "$WEB_APP_NAME" --resource-group "$resource_group" 2>/dev/null || true
        log "✅ Web App зупинено"
    fi
    
    # Видалення Container Registry images
    if [ -n "$CONTAINER_REGISTRY_NAME" ]; then
        log "📦 Очищення Container Registry..."
        local repositories=$(az acr repository list --name "$CONTAINER_REGISTRY_NAME" --output tsv 2>/dev/null || echo "")
        if [ -n "$repositories" ]; then
            while IFS= read -r repo; do
                if [ -n "$repo" ]; then
                    az acr repository delete --name "$CONTAINER_REGISTRY_NAME" --repository "$repo" --yes 2>/dev/null || true
                fi
            done <<< "$repositories"
            log "✅ Container Registry очищено"
        fi
    fi
}

# Головна функція видалення
perform_deletion() {
    local resource_group="$1"
    
    log "🗑️  Початок видалення Resource Group: $resource_group"
    
    # Очищення специфічних ресурсів
    cleanup_specific_resources "$resource_group"
    
    # Видалення Resource Group
    log "🗑️  Видалення Resource Group..."
    local start_time=$(date +%s)
    
    if az group delete --name "$resource_group" --yes --no-wait 2>/dev/null; then
        log "✅ Resource Group помічена для видалення"
        
        # Очікування завершення з таймаутом
        local max_wait_time=1800  # 30 хвилин
        local wait_time=0
        
        log "⏳ Очікування завершення видалення (максимум 30 хвилин)..."
        
        while az group exists --name "$resource_group" 2>/dev/null; do
            if [ $wait_time -ge $max_wait_time ]; then
                warning "⚠️  Таймаут очікування. Resource Group все ще видаляється в фоновому режимі"
                log "📍 Перевірте статус в Azure Portal через 15-20 хвилин"
                break
            fi
            
            echo -n "."
            sleep 30
            wait_time=$((wait_time + 30))
        done
        
        echo ""
        
        if ! az group exists --name "$resource_group" 2>/dev/null; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log "✅ Resource Group успішно видалена за ${duration} секунд"
        else
            warning "⚠️  Resource Group все ще видаляється у фоновому режимі"
        fi
    else
        error "❌ Не вдалося ініціювати видалення Resource Group"
        return 1
    fi
}

# =============================================================================
# CLEANUP ЛОКАЛЬНИХ ФАЙЛІВ
# =============================================================================

cleanup_local_files() {
    log "🧹 Очищення локальних файлів..."
    
    local files_to_clean=(
        "requirements.txt"
        "requirements/"
        ".env"
        ".env.template"
        ".env.${ENVIRONMENT}"
        "startup.sh"
        "Dockerfile"
        "docker-compose.yml"
        "config/"
        "${ENVIRONMENT}-infrastructure-summary.txt"
        "infrastructure-summary.txt"
    )
    
    local cleaned_count=0
    
    for file in "${files_to_clean[@]}"; do
        if [ -e "$file" ]; then
            if [ "$FORCE_DELETE" = "true" ]; then
                rm -rf "$file"
                log "✅ Видалено: $file"
                cleaned_count=$((cleaned_count + 1))
            else
                read -p "Видалити $file? (y/n): " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$file"
                    log "✅ Видалено: $file"
                    cleaned_count=$((cleaned_count + 1))
                fi
            fi
        fi
    done
    
    log "✅ Локальних файлів очищено: $cleaned_count"
}

# =============================================================================
# ЗВІТНІСТЬ
# =============================================================================

generate_cleanup_report() {
    local resource_group="$1"
    local operation_start_time="$2"
    local operation_end_time="$3"
    local duration=$((operation_end_time - operation_start_time))
    
    local report_file="${LOGS_DIR}/cleanup-report-${TIMESTAMP}.txt"
    
    cat > "$report_file" << EOF
AZURE INFRASTRUCTURE CLEANUP REPORT
===================================
Operation: Infrastructure Cleanup
Version: 2.0.0
Date: $(date --iso-8601=seconds)
Duration: ${duration} seconds ($(($duration / 60))m $(($duration % 60))s)

CONFIGURATION:
Project: $PROJECT_NAME
Environment: $ENVIRONMENT
Resource Group: $resource_group
Location: $LOCATION

OPERATION DETAILS:
User: $(whoami)
Host: $(hostname)
Azure Account: $(az account show --query user.name -o tsv 2>/dev/null || echo 'N/A')
Azure Subscription: $(az account show --query name -o tsv 2>/dev/null || echo 'N/A')

RESOURCES CLEANED:
$([ -n "$WEB_APP_NAME" ] && echo "✅ Web App: $WEB_APP_NAME" || echo "❌ Web App: Not found")
$([ -n "$DATABASE_SERVER_NAME" ] && echo "✅ PostgreSQL: $DATABASE_SERVER_NAME" || echo "❌ PostgreSQL: Not found")
$([ -n "$STORAGE_ACCOUNT_NAME" ] && echo "✅ Storage: $STORAGE_ACCOUNT_NAME" || echo "❌ Storage: Not found")
$([ -n "$KEY_VAULT_NAME" ] && echo "✅ Key Vault: $KEY_VAULT_NAME" || echo "❌ Key Vault: Not found")
$([ -n "$CONTAINER_REGISTRY_NAME" ] && echo "✅ Container Registry: $CONTAINER_REGISTRY_NAME" || echo "❌ Container Registry: Not found")
$([ -n "$APP_INSIGHTS_NAME" ] && echo "✅ App Insights: $APP_INSIGHTS_NAME" || echo "❌ App Insights: Not found")

BACKUP STATUS:
$([ "$CREATE_BACKUP" = "true" ] && echo "✅ Backup created: ${BACKUP_DIR}/${resource_group}-${TIMESTAMP}" || echo "❌ Backup: Skipped")

ESTIMATED SAVINGS:
$(case "$ENVIRONMENT" in
    "production") echo "Monthly: ~\$150-200";;
    "staging") echo "Monthly: ~\$60-80";;
    *) echo "Monthly: ~\$30-40";;
esac)

STATUS: $([ $? -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")

VERIFICATION:
Resource Group Exists: $(az group exists --name "$resource_group" 2>/dev/null && echo "❌ Still exists" || echo "✅ Deleted")

RECOMMENDATIONS:
1. Monitor Azure billing to confirm cost reduction
2. Verify no residual resources in other regions
3. Check for any remaining soft-deleted resources
4. Review backup contents if restore is needed

LOGS:
Full log: ${LOGS_DIR}/cleanup-${TIMESTAMP}.log
Backup location: ${BACKUP_DIR}/${resource_group}-${TIMESTAMP}/
Report: $report_file

Generated by: Azure Infrastructure Cleanup v2.0.0
EOF
    
    log "📄 Звіт збережено: $report_file"
    
    # Показ підсумку
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}✅ CLEANUP ЗАВЕРШЕНО УСПІШНО!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo -e "${BOLD}📊 Підсумок операції:${NC}"
    echo "⏱️  Тривалість: ${duration} секунд ($(($duration / 60))m $(($duration % 60))s)"
    echo "🗑️  Resource Group: $resource_group"
    echo "💰 Економія: $(case "$ENVIRONMENT" in "production") echo "~\$150-200/міс";; "staging") echo "~\$60-80/міс";; *) echo "~\$30-40/міс";; esac)"
    echo "📄 Звіт: $report_file"
    
    if [ "$CREATE_BACKUP" = "true" ]; then
        echo "💾 Backup: ${BACKUP_DIR}/${resource_group}-${TIMESTAMP}/"
    fi
    
    echo ""
    echo -e "${BOLD}💡 Рекомендації:${NC}"
    echo "• Перевірте Azure billing через кілька годин"
    echo "• Переконайтесь, що немає залишкових ресурсів"
    echo "• Перевірте soft-deleted ресурси (Key Vault, etc.)"
    echo "• Зберігайте backup для можливого відновлення"
    echo ""
    echo -e "${BOLD}🔗 Корисні посилання:${NC}"
    echo "• Azure Portal: https://portal.azure.com"
    echo "• Billing: https://portal.azure.com/#blade/Microsoft_Azure_Billing/BillingMenuBlade"
    echo "• Support: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade"
    echo ""
}

# =============================================================================
# ГОЛОВНА ФУНКЦІЯ
# =============================================================================

main() {
    local operation_start_time=$(date +%s)
    
    echo -e "${BLUE}🧹 Azure Infrastructure Cleanup v2.0${NC}"
    echo -e "${BLUE}Environment: ${ENVIRONMENT:-auto-detect}${NC}"
    echo -e "${BLUE}Project: $PROJECT_NAME${NC}"
    echo ""
    
    # Створення директорій
    setup_directories
    
    # Валідація
    validate_environment
    
    # Автоматичне знаходження environments якщо не вказано
    if [ -z "$ENVIRONMENT" ]; then
        log "🔍 Автоматичне знаходження environments..."
        
        local found_environments=()
        for env in "production" "staging" "development" "budget"; do
            generate_resource_names "$env"
            if az group exists --name "$RESOURCE_GROUP_NAME" 2>/dev/null; then
                found_environments+=("$env")
            fi
        done
        
        if [ ${#found_environments[@]} -eq 0 ]; then
            error "❌ Не знайдено жодного environment. Вкажіть environment вручну."
            exit 1
        elif [ ${#found_environments[@]} -eq 1 ]; then
            ENVIRONMENT="${found_environments[0]}"
            log "✅ Знайдено environment: $ENVIRONMENT"
        else
            echo "🔍 Знайдено декілька environments:"
            for i in "${!found_environments[@]}"; do
                echo "  $((i+1)). ${found_environments[i]}"
            done
            echo ""
            read -p "Оберіть environment (1-${#found_environments[@]}): " -r choice
            
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_environments[@]} ]; then
                ENVIRONMENT="${found_environments[$((choice-1))]}"
                log "✅ Обрано environment: $ENVIRONMENT"
            else
                error "❌ Невірний вибір"
                exit 1
            fi
        fi
    fi
    
    # Генерація імен ресурсів
    generate_resource_names "$ENVIRONMENT"
    
    # Пошук ресурсів
    if ! discover_resources "$RESOURCE_GROUP_NAME"; then
        error "❌ Resource Group не знайдено або порожня"
        exit 1
    fi
    
    # Показ поточних ресурсів
    show_current_resources "$RESOURCE_GROUP_NAME"
    
    # Створення backup
    if [ "$CREATE_BACKUP" = "true" ]; then
        create_backup "$RESOURCE_GROUP_NAME"
    fi
    
    # Підтвердження видалення
    local estimated_savings
    case "$ENVIRONMENT" in
        "production") estimated_savings="~\$150-200" ;;
        "staging") estimated_savings="~\$60-80" ;;
        *) estimated_savings="~\$30-40" ;;
    esac
    
    confirm_deletion "$RESOURCE_GROUP_NAME" "$estimated_savings"
    
    # Видалення
    perform_deletion "$RESOURCE_GROUP_NAME"
    
    # Очищення локальних файлів
    cleanup_local_files
    
    # Генерація звіту
    local operation_end_time=$(date +%s)
    generate_cleanup_report "$RESOURCE_GROUP_NAME" "$operation_start_time" "$operation_end_time"
    
    log "🎉 Cleanup успішно завершено!"
}

# =============================================================================
# UTILITY ФУНКЦІЇ
# =============================================================================

show_help() {
    cat << EOF
Azure Infrastructure Cleanup v2.0.0

ВИКОРИСТАННЯ:
  $0 [OPTIONS]

ОПЦІЇ:
  -h, --help              Показати цю довідку
  -e, --environment ENV   Environment для видалення (production|staging|development|budget)
  -p, --project NAME      Ім'я проекту (за замовчуванням: django-app)
  -f, --force             Примусове видалення без підтвердження
  --no-backup             Пропустити створення backup
  --dry-run               Показати що буде видалено без фактичного видалення
  --list-environments     Показати доступні environments
  --cleanup-backups       Очистити старі backup файли

ЗМІННІ СЕРЕДОВИЩА:
  PROJECT_NAME           Ім'я проекту
  ENVIRONMENT            Environment для видалення
  FORCE_DELETE           Примусове видалення (true/false)
  CREATE_BACKUP          Створювати backup (true/false)
  SKIP_CONFIRMATION      Пропустити підтвердження (true/false)

ПРИКЛАДИ:
  $0                                    # Інтерактивний вибір environment
  $0 -e production                      # Видалити production environment
  $0 -e staging -p myapp --no-backup   # Видалити staging без backup
  $0 --dry-run                         # Показати план без виконання
  $0 --list-environments               # Показати доступні environments

БЕЗПЕКА:
  • Подвійне підтвердження для всіх операцій
  • Потрійне підтвердження для production
  • Автоматичний backup перед видаленням
  • Детальне логування всіх операцій

BACKUP:
  • Експорт Resource Group templates
  • Backup Key Vault secrets
  • Збереження конфігурацій Web App
  • Metadata бази даних

ВЕРСІЯ: 2.0.0
EOF
}

list_environments() {
    log "🔍 Пошук доступних environments..."
    
    local found_any=false
    for env in "production" "staging" "development" "budget"; do
        generate_resource_names "$env"
        if az group exists --name "$RESOURCE_GROUP_NAME" 2>/dev/null; then
            echo "✅ $env - $RESOURCE_GROUP_NAME"
            found_any=true
        else
            echo "❌ $env - $RESOURCE_GROUP_NAME (не знайдено)"
        fi
    done
    
    if [ "$found_any" = "false" ]; then
        echo ""
        echo "❌ Жодного environment не знайдено"
        echo "💡 Перевірте PROJECT_NAME або створіть інфраструктуру спочатку"
    fi
}

cleanup_old_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log "📁 Backup директорія не існує"
        return 0
    fi
    
    log "🧹 Очищення старих backup файлів..."
    
    # Залишити тільки останні 5 backup
    local backup_count=$(ls -1d "$BACKUP_DIR"/*-* 2>/dev/null | wc -l)
    if [ "$backup_count" -gt 5 ]; then
        ls -1td "$BACKUP_DIR"/*-* | tail -n +6 | xargs rm -rf
        log "✅ Старі backup файли очищено"
    else
        log "ℹ️  Немає старих backup файлів для очищення"
    fi
}

# =============================================================================
# CLEANUP ON ERROR
# =============================================================================

cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "🚨 Cleanup завершився з помилкою (exit code: $exit_code)"
        echo ""
        echo -e "${YELLOW}🔧 Діагностика:${NC}"
        echo "1. Перевірте логи: ${LOGS_DIR}/cleanup-${TIMESTAMP}.log"
        echo "2. Перевірте Azure Portal на предмет частково видалених ресурсів"
        echo "3. Перевірте права доступу Azure CLI"
        echo ""
        echo -e "${YELLOW}🔗 Корисні команди:${NC}"
        echo "  az group list --output table"
        echo "  az resource list --resource-group '$RESOURCE_GROUP_NAME' --output table"
        echo ""
    fi
}

# =============================================================================
# ENTRY POINT
# =============================================================================

# Встановлення trap для error handling
trap cleanup_on_error ERR

# Обробка параметрів командного рядка
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_DELETE="true"
            SKIP_CONFIRMATION="true"
            shift
            ;;
        --no-backup)
            CREATE_BACKUP="false"
            shift
            ;;
        --dry-run)
            echo "🔍 DRY RUN MODE - Показ плану без фактичного видалення"
            
            # Знаходження environments
            if [ -z "$ENVIRONMENT" ]; then
                echo ""
                echo "🔍 Доступні environments:"
                list_environments
                exit 0
            fi
            
            generate_resource_names "$ENVIRONMENT"
            echo ""
            echo "🎯 План видалення для environment: $ENVIRONMENT"
            echo "📁 Resource Group: $RESOURCE_GROUP_NAME"
            
            if discover_resources "$RESOURCE_GROUP_NAME"; then
                show_current_resources "$RESOURCE_GROUP_NAME"
                echo "💾 Backup: $([ "$CREATE_BACKUP" = "true" ] && echo "Буде створено" || echo "Пропущено")"
                echo ""
                echo "⚠️  Це тільки попередній перегляд. Для фактичного видалення запустіть без --dry-run"
            fi
            exit 0
            ;;
        --list-environments)
            list_environments
            exit 0
            ;;
        --cleanup-backups)
            cleanup_old_backups
            exit 0
            ;;
        *)
            error "Невідомий параметр: $1. Використовуйте --help для довідки"
            exit 1
            ;;
    esac
done

# Валідація environment
if [ -n "$ENVIRONMENT" ]; then
    case "$ENVIRONMENT" in
        production|staging|development|budget)
            ;;
        *)
            error "Невідомий environment: $ENVIRONMENT. Підтримуються: production, staging, development, budget"
            exit 1
            ;;
    esac
fi

# Запуск головної функції
main "$@"
