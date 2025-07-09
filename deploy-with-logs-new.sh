#!/bin/bash
# =============================================================================
# ПОКРАЩЕНИЙ Wrapper скрипт для запуску deployment з логуванням
# Версія: 2.0.0
# Покращення: Error handling, Health checks, Production-ready
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
readonly LOGS_DIR="${SCRIPT_DIR}/logs"
readonly CONFIG_FILE="${SCRIPT_DIR}/.deploy-config"
readonly MAX_LOG_FILES=10

# Функції для логування
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR $(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING $(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${CYAN}[INFO $(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# Функція для створення директорій
setup_directories() {
    mkdir -p "$LOGS_DIR"
    
    # Очищення старих логів
    if [ "$(ls -1 "$LOGS_DIR" 2>/dev/null | wc -l)" -gt $MAX_LOG_FILES ]; then
        log "🧹 Очищення старих логів (зберігаємо останні $MAX_LOG_FILES)"
        ls -1t "$LOGS_DIR"/azure-deploy-*.log 2>/dev/null | tail -n +$((MAX_LOG_FILES + 1)) | xargs -r rm -f
    fi
}

# Функція для валідації середовища
validate_environment() {
    local errors=0
    
    info "🔍 Валідація середовища..."
    
    # Перевірка Azure CLI
    if ! command -v az &> /dev/null; then
        error "❌ Azure CLI не встановлено"
        errors=$((errors + 1))
    else
        local az_version=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
        info "✅ Azure CLI version: $az_version"
    fi
    
    # Перевірка авторизації Azure
    if ! az account show &> /dev/null; then
        error "❌ Не авторизовані в Azure CLI. Виконайте: az login"
        errors=$((errors + 1))
    else
        local account_name=$(az account show --query user.name -o tsv 2>/dev/null)
        local subscription_name=$(az account show --query name -o tsv 2>/dev/null)
        info "✅ Azure Account: $account_name"
        info "✅ Azure Subscription: $subscription_name"
    fi
    
    # Перевірка Git
    if command -v git &> /dev/null; then
        local git_branch=$(git branch --show-current 2>/dev/null || echo 'N/A')
        local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
        info "✅ Git Branch: $git_branch"
        info "✅ Git Commit: $git_commit"
    fi
    
    # Перевірка Docker (опціонально)
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            info "✅ Docker доступний"
        else
            warning "⚠️  Docker встановлений, але не запущений"
        fi
    fi
    
    return $errors
}

# Функція для створення header лога
create_log_header() {
    local script_name="$1"
    local deployment_type="${2:-standard}"
    
    cat << EOF
================================================================================
Azure Django Infrastructure Deployment Log v2.0
================================================================================
Timestamp: $(date --iso-8601=seconds)
User: $(whoami)
Host: $(hostname)
Working Directory: $(pwd)
Script: $script_name
Deployment Type: $deployment_type
Environment: ${ENVIRONMENT:-production}
Git Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')
Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
Git Remote: $(git remote get-url origin 2>/dev/null || echo 'N/A')
Azure Account: $(az account show --query user.name -o tsv 2>/dev/null || echo 'Not logged in')
Azure Subscription: $(az account show --query name -o tsv 2>/dev/null || echo 'N/A')
Azure Subscription ID: $(az account show --query id -o tsv 2>/dev/null || echo 'N/A')
Azure CLI Version: $(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo 'N/A')
Shell: $SHELL
Script PID: $$
================================================================================

EOF
}

# Функція для health check після розгортання
perform_health_check() {
    local app_name="$1"
    local resource_group="$2"
    local max_attempts=10
    local attempt=1
    
    info "🏥 Початок health check для $app_name"
    
    # Отримання URL додатку
    local app_url=$(az webapp show --name "$app_name" --resource-group "$resource_group" --query "defaultHostName" -o tsv 2>/dev/null)
    
    if [ -z "$app_url" ]; then
        warning "⚠️  Не вдалося отримати URL додатку"
        return 1
    fi
    
    log "🌐 Перевірка доступності: https://$app_url"
    
    # Перевірка доступності
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s -o /dev/null "https://$app_url" --max-time 30; then
            log "✅ Health check пройшов успішно (спроба $attempt/$max_attempts)"
            return 0
        else
            warning "⚠️  Health check невдалий (спроба $attempt/$max_attempts)"
            if [ $attempt -lt $max_attempts ]; then
                info "⏳ Очікування 30 секунд перед наступною спробою..."
                sleep 30
            fi
        fi
        attempt=$((attempt + 1))
    done
    
    error "❌ Health check провалився після $max_attempts спроб"
    return 1
}

# Функція для показу підсумку
show_summary() {
    local exit_code=$1
    local duration=$2
    local script_name=$3
    
    echo ""
    echo "================================================================================"
    echo "DEPLOYMENT SUMMARY"
    echo "================================================================================"
    echo "Status: $([ $exit_code -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")"
    echo "Script: $script_name"
    echo "Duration: ${duration} seconds ($(($duration / 60))m $(($duration % 60))s)"
    echo "Log file: ${LOG_FILE}"
    echo "Exit code: ${exit_code}"
    echo "Completed: $(date --iso-8601=seconds)"
    echo "================================================================================"
}

# Функція для показу корисних команд
show_useful_commands() {
    echo ""
    echo -e "${BLUE}📋 Корисні команди:${NC}"
    echo "Переглянути лог:           cat '$LOG_FILE'"
    echo "Відкрити лог у VS Code:    code '$LOG_FILE'"
    echo "Останні помилки:           grep -i 'error\\|failed' '$LOG_FILE'"
    echo "Останні кроки:             grep 'КРОК\\|STEP' '$LOG_FILE'"
    echo "Показати warnings:         grep -i 'warning' '$LOG_FILE'"
    echo "Показати створені ресурси: grep -i 'створено\\|created' '$LOG_FILE'"
    echo "Аналіз performance:        grep -i 'duration\\|time' '$LOG_FILE'"
    echo ""
    echo -e "${BLUE}🔧 Операції:${NC}"
    echo "Перевірити Azure ресурси:  az resource list --output table"
    echo "Показати App Service:      az webapp list --output table"
    echo "Показати витрати:          az consumption usage list --output table"
    echo ""
}

# Функція для cleanup при виході
cleanup() {
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        error "🚨 Скрипт завершився з помилкою (exit code: $exit_code)"
        echo ""
        echo -e "${RED}🔍 Останні рядки логу:${NC}"
        tail -n 10 "$LOG_FILE" 2>/dev/null || echo "Не вдалося прочитати лог"
        echo ""
        echo -e "${YELLOW}💡 Для діагностики виконайте:${NC}"
        echo "  grep -i 'error\\|failed' '$LOG_FILE'"
        echo "  az webapp log tail --name [app-name] --resource-group [resource-group]"
    fi
    
    exit $exit_code
}

# Функція для збереження конфігурації
save_deployment_config() {
    local script_name="$1"
    local log_file="$2"
    
    cat > "$CONFIG_FILE" << EOF
# Конфігурація останнього розгортання
LAST_DEPLOYMENT_SCRIPT="$script_name"
LAST_DEPLOYMENT_LOG="$log_file"
LAST_DEPLOYMENT_TIME="$(date --iso-8601=seconds)"
LAST_DEPLOYMENT_USER="$(whoami)"
LAST_DEPLOYMENT_HOST="$(hostname)"
EOF
}

# Основна функція
main() {
    local script_name="$1"
    local deployment_type="${2:-standard}"
    
    # Встановлення trap для cleanup
    trap cleanup EXIT
    
    # Ініціалізація
    local timestamp=$(date +%Y%m%d-%H%M%S)
    readonly LOG_FILE="$LOGS_DIR/azure-deploy-${timestamp}.log"
    
    # Створення директорій
    setup_directories
    
    # Валідація середовища
    if ! validate_environment; then
        error "❌ Валідація середовища провалилася"
        exit 1
    fi
    
    # Перевірка існування скрипта
    if [ ! -f "$script_name" ]; then
        error "❌ Скрипт '$script_name' не знайдено"
        echo "Доступні скрипти:"
        ls -la *.sh 2>/dev/null | grep -v "$(basename "$0")" || echo "Немає .sh файлів у поточній папці"
        exit 1
    fi
    
    # Перевірка прав на виконання
    if [ ! -x "$script_name" ]; then
        warning "⚠️  Надання прав на виконання для $script_name"
        chmod +x "$script_name"
    fi
    
    # Показ інформації
    echo -e "${BLUE}🚀 Запуск Azure Django Deployment v2.0${NC}"
    echo -e "${BLUE}📝 Логи зберігаються у: ${LOG_FILE}${NC}"
    echo -e "${BLUE}📊 Тип розгортання: ${deployment_type}${NC}"
    echo ""
    
    # Початок таймера
    local start_time=$(date +%s)
    
    # Створення header лога
    create_log_header "$script_name" "$deployment_type" > "$LOG_FILE"
    
    log "▶️  Запуск скрипта: $script_name"
    log "🎯 Тип розгортання: $deployment_type"
    
    # Запуск скрипту з логуванням
    local exit_code=0
    if ! "./$script_name" 2>&1 | tee -a "$LOG_FILE"; then
        exit_code=$?
    fi
    
    # Кінець таймера
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Додати підсумок у лог
    show_summary $exit_code $duration "$script_name" | tee -a "$LOG_FILE"
    
    # Health check для успішних розгортань
    if [ $exit_code -eq 0 ] && [ "$deployment_type" != "cleanup" ]; then
        info "🏥 Виконання health check..."
        # Спроба автоматично знайти app name та resource group з логу
        local app_name=$(grep -o 'Web App: [^[:space:]]*' "$LOG_FILE" | tail -1 | cut -d' ' -f3)
        local resource_group=$(grep -o 'Resource Group: [^[:space:]]*' "$LOG_FILE" | tail -1 | cut -d' ' -f3)
        
        if [ -n "$app_name" ] && [ -n "$resource_group" ]; then
            perform_health_check "$app_name" "$resource_group" || warning "⚠️  Health check не пройшов"
        fi
    fi
    
    # Збереження конфігурації
    save_deployment_config "$script_name" "$LOG_FILE"
    
    # Показ корисних команд
    show_useful_commands
    
    exit $exit_code
}

# Функція для показу допомоги
show_help() {
    cat << EOF
Azure Django Deployment Wrapper v2.0

ВИКОРИСТАННЯ:
  $0 <script-name> [deployment-type]

ПАРАМЕТРИ:
  script-name      - Шлях до скрипта розгортання
  deployment-type  - Тип розгортання (standard|production|cleanup)

ОПЦІЇ:
  -h, --help      - Показати цю довідку
  -v, --version   - Показати версію
  --validate      - Тільки валідувати середовище

ПРИКЛАДИ:
  $0 azure-deploy.sh production
  $0 cleanup-infrastructure.sh cleanup
  $0 --validate

ФАЙЛИ:
  logs/           - Директорія з логами
  .deploy-config  - Конфігурація останнього розгортання

ВИМОГИ:
  - Azure CLI (az)
  - Git (опціонально)
  - Docker (опціонально)

ВЕРСІЯ: 2.0.0
EOF
}

# Обробка параметрів командного рядка
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        echo "Azure Django Deployment Wrapper v2.0.0"
        exit 0
        ;;
    --validate)
        setup_directories
        readonly LOG_FILE="$LOGS_DIR/validation-$(date +%Y%m%d-%H%M%S).log"
        validate_environment
        exit $?
        ;;
    "")
        echo "Помилка: Не вказано скрипт для запуску"
        echo "Використання: $0 <script-name> [deployment-type]"
        echo "Для довідки: $0 --help"
        exit 1
        ;;
    *)
        main "$@"
        ;;
esac
