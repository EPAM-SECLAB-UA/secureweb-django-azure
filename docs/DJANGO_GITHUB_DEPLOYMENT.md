

```bash
 # Налаштуйте GitHub deployment замість ZIP
az webapp deployment source config \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --repo-url https://github.com/EPAM-SECLAB-UA/secureweb-django-azure \
    --branch feature/infrastructure-update \
    --manual-integration
```


```bash
@VitaliiShevchuk2023 ➜ /workspaces/secureweb-django-azure (feature/infrastructure-update) $ az webapp deployment source config \
>     --name django-app-budget-1752082786 \
>     --resource-group django-app-budget-rg \
>     --repo-url https://github.com/EPAM-SECLAB-UA/secureweb-django-azure \
>     --branch feature/infrastructure-update \
>     --manual-integration
location is not a known attribute of class <class 'azure.mgmt.web.v2023_12_01.models._models_py3.SiteSourceControl'> and will be ignored
{
  "branch": "feature/infrastructure-update",
  "deploymentRollbackEnabled": false,
  "gitHubActionConfiguration": null,
  "id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/Microsoft.Web/sites/django-app-budget-1752082786/sourcecontrols/web",
  "isGitHubAction": false,
  "isManualIntegration": true,
  "isMercurial": false,
  "kind": null,
  "location": "West Europe",
  "name": "django-app-budget-1752082786",
  "repoUrl": "https://github.com/EPAM-SECLAB-UA/secureweb-django-azure",
  "resourceGroup": "django-app-budget-rg",
  "tags": {
    "CostProfile": "Budget",
    "CreatedBy": "AzureCLI",
    "Environment": "budget",
    "Project": "django-app",
    "hidden-link: /app-insights-resource-id": "/subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg/providers/microsoft.insights/components/django-app-budget-insights"
  },
  "type": "Microsoft.Web/sites/sourcecontrols"
}
```


Відмінно! GitHub deployment налаштовано. Тепер Azure буде автоматично розгортати з вашого репозиторію. Давайте налаштуємо все правильно:

## ✅ **GitHub deployment налаштовано успішно!**

### **1. Тепер встановіть критичні змінні для build:**
```bash
az webapp config appsettings set \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --settings \
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
        ENABLE_ORYX_BUILD="true" \
        DJANGO_SETTINGS_MODULE="project_portfolio.settings" \
        SECRET_KEY="$(openssl rand -base64 32)" \
        DEBUG="False" \
        PYTHONPATH="/home/site/wwwroot"
```

### **2. Встановіть правильну startup команду:**
```bash
az webapp config set \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --startup-file "gunicorn --bind=0.0.0.0:8000 --timeout 120 --workers 1 project_portfolio.wsgi:application"
```

### **3. Запустіть синхронізацію з GitHub:**
```bash
az webapp deployment source sync \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg
```

### **4. Слідкуйте за процесом deployment:**
```bash
# Моніторинг логів
az webapp log tail \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg
```

## 🔍 **Що відбувається зараз:**

1. **Azure клонує ваш репозиторій** з branch `feature/infrastructure-update`
2. **Oryx build** встановлює залежності з `requirements.txt`
3. **Gunicorn запускає** Django проект

### **5. Перевірте статус deployment:**
```bash
# Статус останнього deployment
az webapp deployment list \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --output table

# Деталі deployment
az webapp deployment show \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --deployment-id "latest"
```

### **6. Якщо потрібно внести зміни в код:**

Тепер коли GitHub deployment налаштований, будь-які зміни в репозиторії можна розгорнути так:

```bash
# Після push в GitHub
az webapp deployment source sync \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg
```

## 📊 **Очікуваний результат:**

За 5-10 хвилин повинен з'явитися працюючий Django сайт:
```
https://django-app-budget-1752082786.azurewebsites.net
```

### **7. Перевірка через кілька хвилин:**
```bash
# Перевірка HTTP статусу
curl -I https://django-app-budget-1752082786.azurewebsites.net

# Якщо працює, відкрийте в браузері
az webapp browse \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg
```

## 🎯 **Переваги GitHub deployment:**

- ✅ **Автоматична установка залежностей** через Oryx
- ✅ **Правильний Python environment**
- ✅ **Консистентні deployment**
- ✅ **Логування процесу**

Якщо все пройде успішно, ви побачите ваш Django додаток працюючим на Azure! 🚀
