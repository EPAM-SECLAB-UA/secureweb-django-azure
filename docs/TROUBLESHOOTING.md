

```bash
Failed to update diagnostics for 'django-app-budget-1752082786'.{"error":{"code":"LinkedAuthorizationFailed","message":"The client 'vitalii_shevchuk3@epam.com' with object id '2b519bbb-fa41-470c-9279-95f55f66c3b9' has permission to perform action 'microsoft.insights/diagnosticSettings/write' on scope '/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786/providers/microsoft.insights/diagnosticSettings/django-app-log'; however, it does not have permission to perform action 'Microsoft.OperationalInsights/workspaces/sharedKeys/action' on the '0' linked scope(s) '' or the linked scope(s) are invalid and is blocked by deny assignments on the '1' linked scope(s) '/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/ai_django-app-budget-insights_339b7677-3cc1-4888-a6de-5f66c24dba53_managed/providers/Microsoft.OperationalInsights/workspaces/managed-django-app-budget-insights-ws'."}}.
```

🚨 **Помилка авторизації для Diagnostic Settings**

Проблема: у вас немає прав на `Microsoft.OperationalInsights/workspaces/sharedKeys/action` для managed Log Analytics workspace.

## 🔧 **Способи вирішення:**

### **1. 🥇 Через Azure CLI (найпростіший):**

```bash
# Увімкніть Application Logs через Azure CLI
az webapp log config \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --application-logging azureblobstorage \
    --level information \
    --detailed-error-messages true \
    --failed-request-tracing true
```

### **2. 🔐 Отримайте додаткові права:**

```bash
# Спробуйте отримати Contributor роль на Log Analytics workspace
az role assignment create \
    --assignee "vitalii_shevchuk3@epam.com" \
    --role "Log Analytics Contributor" \
    --scope "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/ai_django-app-budget-insights_339b7677-3cc1-4888-a6de-5f66c24dba53_managed/providers/Microsoft.OperationalInsights/workspaces/managed-django-app-budget-insights-ws"
```

### **3. 🎯 Створіть власний Log Analytics workspace:**

```bash
# Створіть власний workspace (у вашій resource group)
az monitor log-analytics workspace create \
    --resource-group django-app-budget-rg \
    --workspace-name "django-app-custom-logs" \
    --location "West Europe" \
    --sku "PerGB2018"

# Отримайте ID нового workspace
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group django-app-budget-rg \
    --workspace-name "django-app-custom-logs" \
    --query "id" -o tsv)

echo "Workspace ID: $WORKSPACE_ID"
```

### **4. 🛠️ Альтернатива - Storage Account для логів:**

```bash
# Створіть storage account для логів
az storage account create \
    --name "djangoapplogsstorage$(date +%s)" \
    --resource-group django-app-budget-rg \
    --location "West Europe" \
    --sku "Standard_LRS"

# Налаштуйте логування в storage
az webapp log config \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --application-logging azureblobstorage \
    --level information
```

### **5. 📝 Мінімальне логування через файлову систему:**

```bash
# Увімкніть базове логування в файлову систему
az webapp log config \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --application-logging filesystem \
    --level information \
    --detailed-error-messages true \
    --failed-request-tracing true \
    --web-server-logging filesystem
```

## 📊 **Перевірка поточних налаштувань:**

```bash
# Подивіться поточну конфігурацію логів
az webapp log show \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786

# Перегляд real-time логів
az webapp log tail \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786
```

## 🔍 **Альтернативні способи моніторингу:**

### **1. Application Insights (якщо доступний):**
```bash
# Перевірте чи є App Insights
az monitor app-insights component show \
    --app "django-app-budget-insights" \
    --resource-group django-app-budget-rg
```

### **2. Django логування в файли:**
```python
# У settings.py додайте простий file-based logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': '/tmp/django.log',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file', 'console'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```


```
## 🎯 **Рекомендований план дій:**

### **Крок 1 - Спробуйте filesystem logging:**
```bash
az webapp log config \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786 \
    --application-logging filesystem \
    --level information
```

### **Крок 2 - Якщо не працює, зверніться до EPAM admin:**
Попросіть додати права:
- `Log Analytics Contributor` роль
- або `Microsoft.OperationalInsights/workspaces/sharedKeys/action` permission

### **Крок 3 - Перевірте результат:**
```bash
az webapp log tail \
    --resource-group django-app-budget-rg \
    --name django-app-budget-1752082786
```

**Найвірогідніше filesystem logging буде працювати без додаткових прав!** 🚀


```bash
^C@VitaliiShevchuk2023 ➜ /workspaces/secureweb-django-azure (feature/infrastructure-update) $ az webapp log show \
>     --resource-group django-app-budget-rg \
>     --name django-app-budget-1752082786
{
  "applicationLogs": {
    "azureBlobStorage": {
      "level": "Off",
      "retentionInDays": null,
      "sasUrl": null
    },
    "azureTableStorage": {
      "level": "Off",
      "sasUrl": null
    },
    "fileSystem": {
      "level": "Information"
    }
  },
  "detailedErrorMessages": {
    "enabled": true
  },
  "failedRequestsTracing": {
    "enabled": true
  },
  "httpLogs": {
    "azureBlobStorage": {
      "enabled": false,
      "retentionInDays": null,
      "sasUrl": null
    },
    "fileSystem": {
      "enabled": false,
      "retentionInDays": null,
      "retentionInMb": 100
    }
  },
  "id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786/config/logs",
  "kind": null,
  "location": "West Europe",
  "name": "logs",
  "resourceGroup": "django-app-budget-rg",
  "tags": {
    "CostProfile": "Budget",
    "CreatedBy": "AzureCLI",
    "Environment": "budget",
    "Project": "django-app",
    "hidden-link: /app-insights-resource-id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/microsoft.insights/components/django-app-budget-insights"
  },
  "type": "Microsoft.Web/sites/config"
}
@VitaliiShevchuk2023 ➜ /workspaces/secureweb-django-azure (feature/infrastructure-update) $ 
```

