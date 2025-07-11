
Ось кілька варіантів назв для файлу з KQL запитами:

## 🎯 Рекомендовані назви:

### **Основний варіант:**
```
azure-log-analytics-queries.md
```

### **Альтернативні варіанти:**

**За функціональністю:**
- `kql-queries-collection.md`
- `log-analytics-kusto-queries.md`
- `monitoring-kql-queries.md`

**За структурою проекту:**
- `docs/monitoring/kql-queries.md`
- `docs/azure/log-analytics-queries.md`
- `docs/operations/monitoring-queries.md`

**За категоріями:**
- `django-app-monitoring-queries.md`
- `azure-monitoring-playbook.md`
- `troubleshooting-kql-queries.md`

## 📁 Рекомендована структура папок:

```
project-root/
├── docs/
│   ├── azure/
│   │   ├── deployment-guide.md
│   │   └── log-analytics-queries.md  ← ЦЕЙ ФАЙЛ
│   ├── monitoring/
│   │   ├── azure-log-analytics-queries.md  ← АБО ЦЕЙ
│   │   ├── alert-rules.md
│   │   └── dashboard-setup.md
│   ├── troubleshooting/
│   │   ├── django-app-troubleshooting-guide.md
│   │   └── performance-monitoring.md
│   └── README.md
```

## 🏷️ Найкращий варіант:

**`docs/monitoring/azure-log-analytics-queries.md`**

**Чому саме цей:**
- ✅ Зрозуміло що це Azure Log Analytics
- ✅ Вказує на KQL/Kusto queries
- ✅ Категоризовано в monitoring папці
- ✅ Легко знайти та згадати
- ✅ Розширюється для інших monitoring topics

## 📋 Рекомендована структура файлу:

```markdown
# Azure Log Analytics Queries

## Memory Monitoring
### Memory Usage Tracking
```kusto
// Memory usage tracking
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory usage" or ResultDescription contains "Memory"
| project TimeGenerated, Level, ResultDescription
| order by TimeGenerated desc
```

## Performance Monitoring
### HTTP Response Times
### CPU Usage Analysis

## Error Tracking  
### OOM Kill Detection
### Application Errors

## Health Monitoring
### Service Availability
### Worker Status
```

## 🔍 Альтернативи для різних use cases:

**Якщо це єдиний monitoring файл:**
```
MONITORING-QUERIES.md
```

**Якщо фокус на troubleshooting:**
```
troubleshooting-kql-queries.md
```

**Якщо частина більшого runbook:**
```
azure-operations-runbook.md
```


## 🔍 **Що робить цей KQL запит**

### 📊 **Пояснення по рядках:**


```kusto
// Memory usage tracking                           ← Коментар
AppServiceConsoleLogs                              ← Вибрати таблицю з консольними логами
| where TimeGenerated > ago(24h)                  ← Фільтр: тільки за останні 24 години
| where ResultDescription contains "memory usage" ← Фільтр: тільки записи що містять "memory usage"
   or ResultDescription contains "Memory"          ← АБО містять "Memory" 
| project TimeGenerated, Level, ResultDescription ← Показати тільки ці 3 колонки
| order by TimeGenerated desc                     ← Сортувати за часом (нові зверху)
```

### 🎯 **Призначення запиту:**

**Знаходить всі записи в консольних логах App Service, які стосуються використання пам'яті за останню добу.**

### 📋 **Що він шукає:**

#### **Типи записів які знайде:**
```bash
# Приклади того що може знайти:
"High memory usage: 85%"
"Memory usage before request: 70%"  
"Critical memory after request: 90%"
"Worker (pid:1079) was sent SIGKILL! Perhaps out of memory?"
"Memory allocation failed"
"Out of Memory error"
```

#### **Структура результату:**
| TimeGenerated | Level | ResultDescription |
|---------------|-------|-------------------|
| 2025-07-11 07:14:00 | Error | Worker (pid:2090) was sent SIGKILL! Perhaps out of memory? |
| 2025-07-11 07:10:00 | Warning | High memory usage: 85% |
| 2025-07-11 07:05:00 | Info | Memory usage before request: 70% |

### 🔍 **Практичне використання:**

#### **1. Виявлення OOM kills:**
```kusto
// Знайде записи типу:
"Worker was sent SIGKILL! Perhaps out of memory?"
```

#### **2. Моніторинг memory trends:**
```kusto
// Знайде custom логи з middleware:
"Memory usage: 85%"
"High memory growth: 15% for /some/path"
```

#### **3. Debug memory issues:**
```kusto
// Допоможе знайти причини:
"Memory allocation failed during image processing"
"Database connection pool exhausted"
```

## 🛠️ **Покращені версії запиту**

### **1. Більш детальний пошук:**
```kusto
// Розширений memory tracking
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory" or 
        ResultDescription contains "Memory" or
        ResultDescription contains "OOM" or
        ResultDescription contains "SIGKILL" or
        ResultDescription contains "out of memory"
| extend Severity = case(
    ResultDescription contains "SIGKILL" or ResultDescription contains "out of memory", "Critical",
    ResultDescription contains "high memory" or ResultDescription contains "Memory" and ResultDescription contains "90", "High", 
    ResultDescription contains "memory usage", "Info",
    "Unknown"
)
| project TimeGenerated, Level, Severity, ResultDescription
| order by TimeGenerated desc
```

### **2. Статистичний аналіз:**
```kusto
// Memory events статистика
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory" or ResultDescription contains "Memory"
| extend EventType = case(
    ResultDescription contains "SIGKILL", "OOM Kill",
    ResultDescription contains "high memory", "High Usage",
    ResultDescription contains "memory usage", "Usage Report",
    "Other"
)
| summarize Count = count() by EventType, bin(TimeGenerated, 1h)
| render columnchart
```

### **3. Memory trend analysis:**
```kusto
// Витягнути числові значення memory usage
AppServiceConsoleLogs
| where TimeGenerated > ago(24h)
| where ResultDescription contains "memory usage"
| extend MemoryPercent = extract(@"memory usage:? (\d+(?:\.\d+)?)%", 1, ResultDescription)
| where isnotempty(MemoryPercent)
| extend MemoryUsage = todouble(MemoryPercent)
| summarize 
    avg(MemoryUsage),
    max(MemoryUsage),
    min(MemoryUsage)
  by bin(TimeGenerated, 1h)
| render timechart
```

## 💡 **Коли використовувати цей запит:**

### **✅ Корисно для:**
- Діагностики OOM kills
- Моніторингу memory trends
- Знаходження memory-related помилок
- Аналізу ефективності оптимізацій

### **⚠️ Обмеження:**
- Знайде тільки те, що явно логується з словами "memory" або "Memory"
- Не покаже memory usage метрики (для цього потрібен інший запит)
- Залежить від того, чи додаток логує memory інформацію

## 🎯 **Практичний приклад використання:**

**Після впровадження memory monitoring middleware** цей запит покаже:
```
2025-07-11 08:30:00 | Warning | High memory usage: 85%
2025-07-11 08:25:00 | Info    | Memory usage before request: 70%
2025-07-11 08:20:00 | Error   | Critical memory after request: 92%
```

**Це допоможе:**
- Виявити коли memory usage критичний
- Знайти які requests споживають багато пам'яті
- Перевірити чи працюють оптимізації

**Простими словами:** Цей запит - це "пошук всього що стосується пам'яті в логах за добу" 🔍

