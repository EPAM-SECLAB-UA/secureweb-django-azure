


Ось повний скрипт для розгортання Django додатку з GitHub! 🚀

## 🎯 **Як використовувати:**

### **1. Збережіть скрипт:**
```bash
# Збережіть як deploy-github-django.sh
chmod +x deploy-github-django.sh
```

### **2. Запустіть з вашими параметрами:**
```bash
# Стандартне розгортання (використовує ваші існуючі ресурси)
./deploy-github-django.sh

# Або з кастомними параметрами
./deploy-github-django.sh \
    --resource-group django-app-budget-rg \
    --webapp-name django-app-budget-1752082786 \
    --db-server django-app-budget-db-1752082786
```

### **3. Перевірка перед запуском:**
```bash
# Dry run - покаже що буде зроблено
./deploy-github-django.sh --dry-run
```

## ✨ **Що робить скрипт:**

### **📦 Підготовка:**
- Клонує репозиторій з GitHub
- Створює production-ready Django конфігурацію
- Генерує requirements.txt з необхідними залежностями

### **⚙️ Конфігурація:**
- Налаштовує змінні середовища Azure App Service
- Встановлює startup команду
- Конфігурує логування

### **🚀 Розгортання:**
- Створює deployment пакет
- Розгортає через Azure CLI
- Перевіряє здоров'я додатку

### **🔧 Особливості:**
- Використовує PostgreSQL з вашої інфраструктури
- Налаштовує production settings
- Увімкнення HTTPS та безпеки
- Автоматичний збір статичних файлів
- Міграції бази даних

## 📋 **Приклад виводу:**
```
🚀 Початок розгортання Django з GitHub на Azure
📦 Клонування репозиторію з GitHub...
🛠️  Підготовка Django додатку для розгортання...
⚙️  Налаштування App Service...
🗄️  Налаштування бази даних...
🚀 Розгортання Django додатку...
🏥 Перевірка здоров'я додатку...
🎉 Розгортання успішно завершено!

🌐 Application URL: https://django-app-budget-1752082786.azurewebsites.net
```

## 🔍 **Якщо щось пішло не так:**
```bash
# Перевірте логи
az webapp log tail --name django-app-budget-1752082786 --resource-group django-app-budget-rg

# Перезапустіть
az webapp restart --name django-app-budget-1752082786 --resource-group django-app-budget-rg
```

Цей скрипт повністю автоматизує розгортання вашого Django проекту з GitHub на існуючу Azure інфраструктуру! 🎯
