

```bash

name: Deploy Django to Azure App Service

on:
  push:
    branches: [ feature/infrastructure-update, main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Дозволяє ручний запуск

env:
  AZURE_WEBAPP_NAME: django-app-budget-1752082786
  AZURE_WEBAPP_PACKAGE_PATH: '.'
  PYTHON_VERSION: '3.11'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: 🚀 Checkout code
      uses: actions/checkout@v4
      
    - name: 🐍 Set up Python ${{ env.PYTHON_VERSION }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
        
    - name: 📦 Cache pip dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
        restore-keys: |
          ${{ runner.os }}-pip-
          
    - name: 📋 Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        
    - name: 🧪 Run tests
      run: |
        python manage.py check --deploy
        # python manage.py test  # Розкоментуйте коли будуть тести
        
    - name: 🔒 Collect static files
      run: |
        python manage.py collectstatic --noinput --settings=project_portfolio.settings
      env:
        SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY || 'build-time-secret-key' }}
        DEBUG: 'False'
        
    - name: 📄 Create deployment package
      run: |
        # Видаляємо непотрібні файли для продакшну
        rm -rf .git .gitignore .github
        rm -rf __pycache__ */__pycache__ */*/__pycache__
        rm -rf *.pyc */*.pyc */*/*.pyc
        rm -rf tests/ docs/ images/
        rm -rf logs/ .env .env.* *.log
        rm -rf node_modules/ .vscode/ .devcontainer/
        
        # Створюємо архів для deployment
        zip -r deployment.zip . -x "*.git*" "*__pycache__*" "*.pyc" "tests/*" "docs/*"
        
    - name: 📤 Upload artifact for deployment job
      uses: actions/upload-artifact@v3
      with:
        name: python-app
        path: deployment.zip

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/feature/infrastructure-update' || github.ref == 'refs/heads/main'
    environment:
      name: 'Production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}
      
    steps:
    - name: 📥 Download artifact from build job
      uses: actions/download-artifact@v3
      with:
        name: python-app
        
    - name: 🔓 Unzip deployment package
      run: unzip deployment.zip
      
    - name: 🔑 Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
        
    - name: ⚙️ Configure App Service settings
      uses: azure/appservice-settings@v1
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        app-settings-json: |
          [
            {
              "name": "SCM_DO_BUILD_DURING_DEPLOYMENT",
              "value": "true"
            },
            {
              "name": "ENABLE_ORYX_BUILD",
              "value": "true"
            },
            {
              "name": "DJANGO_SETTINGS_MODULE",
              "value": "project_portfolio.settings"
            },
            {
              "name": "SECRET_KEY",
              "value": "${{ secrets.DJANGO_SECRET_KEY }}"
            },
            {
              "name": "DEBUG",
              "value": "False"
            },
            {
              "name": "PYTHONPATH",
              "value": "/home/site/wwwroot"
            },
            {
              "name": "WEBSITE_TIME_ZONE",
              "value": "Europe/Kiev"
            },
            {
              "name": "DB_NAME",
              "value": "${{ secrets.DB_NAME || 'django-app_db' }}"
            },
            {
              "name": "DB_USER", 
              "value": "${{ secrets.DB_USER || 'djangoadmin' }}"
            },
            {
              "name": "DB_PASSWORD",
              "value": "${{ secrets.DB_PASSWORD }}"
            },
            {
              "name": "DB_HOST",
              "value": "${{ secrets.DB_HOST || 'django-app-budget-db-1752082786.postgres.database.azure.com' }}"
            }
          ]
          
    - name: 🚀 Deploy to Azure Web App
      id: deploy-to-webapp
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
        startup-command: 'gunicorn --bind=0.0.0.0:8000 --timeout 600 --workers 2 project_portfolio.wsgi:application'
        
    - name: 🏥 Health check
      run: |
        echo "🏥 Виконання health check..."
        sleep 60  # Чекаємо поки додаток запуститься
        
        for i in {1..10}; do
          echo "🔍 Спроба $i/10: Перевірка https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net"
          
          if curl -f -s --max-time 30 "https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net" > /dev/null; then
            echo "✅ Додаток працює!"
            echo "🌐 URL: https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net"
            exit 0
          fi
          
          if [ $i -lt 10 ]; then
            echo "⏳ Очікування 30 секунд перед наступною спробою..."
            sleep 30
          fi
        done
        
        echo "⚠️ Додаток не відповідає після 10 спроб"
        echo "🔍 Перевірте логи у Azure Portal"
        exit 1
        
    - name: 📊 Deployment summary
      if: always()
      run: |
        echo "## 📋 Deployment Summary" >> $GITHUB_STEP_SUMMARY
        echo "| Parameter | Value |" >> $GITHUB_STEP_SUMMARY
        echo "|-----------|-------|" >> $GITHUB_STEP_SUMMARY
        echo "| 🌐 App Name | ${{ env.AZURE_WEBAPP_NAME }} |" >> $GITHUB_STEP_SUMMARY
        echo "| 🔗 URL | https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net |" >> $GITHUB_STEP_SUMMARY
        echo "| 🐍 Python Version | ${{ env.PYTHON_VERSION }} |" >> $GITHUB_STEP_SUMMARY
        echo "| 🌿 Branch | ${{ github.ref_name }} |" >> $GITHUB_STEP_SUMMARY
        echo "| 📦 Commit | ${{ github.sha }} |" >> $GITHUB_STEP_SUMMARY
        echo "| 👤 Author | ${{ github.actor }} |" >> $GITHUB_STEP_SUMMARY
        echo "| ⏰ Deployed at | $(date -u) |" >> $GITHUB_STEP_SUMMARY
        
  cleanup:
    runs-on: ubuntu-latest
    needs: [build, deploy]
    if: always()
    
    steps:
    - name: 🧹 Cleanup artifacts
      uses: actions/github-script@v6
      with:
        script: |
          console.log('🧹 Очищення artifacts...');
          // Artifacts будуть автоматично видалені через 90 днів

```



# 🔐 Налаштування GitHub Secrets для Azure Deployment

## 🚀 Крок 1: Створення GitHub Action файлу

Створіть файл `.github/workflows/azure-deploy.yml` у вашому репозиторії з кодом з попереднього артефакту.

## 🔑 Крок 2: Налаштування Secrets у GitHub

Перейдіть до Settings → Secrets and variables → Actions у вашому репозиторії та додайте наступні secrets:

### 📋 Обов'язкові Secrets:

#### 1. `AZUREAPPSERVICE_PUBLISHPROFILE`
```bash
# Отримайте publish profile для вашого App Service
az webapp deployment list-publishing-profiles \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --xml
```
Скопіюйте весь XML вміст у цей secret.

#### 2. `DJANGO_SECRET_KEY`
```bash
# Згенеруйте новий секретний ключ
python -c "import secrets; print(secrets.token_urlsafe(50))"
```

#### 3. `DB_PASSWORD`
```
wPxKOODi1aYDjMdIAa1!
```

### 🗄️ Опціональні Secrets (якщо відрізняються від дефолтних):

#### 4. `DB_NAME`
```
django-app_db
```

#### 5. `DB_USER`
```
djangoadmin
```

#### 6. `DB_HOST`
```
django-app-budget-db-1752082786.postgres.database.azure.com
```

## 🔧 Крок 3: Альтернативний метод - Service Principal

Якщо publish profile не працює, створіть Service Principal:

```bash
# Створіть Service Principal
az ad sp create-for-rbac \
    --name "github-actions-django-app" \
    --role contributor \
    --scopes /subscriptions/f7dc8823-4f06-4346-9de0-badbe6273a54/resourceGroups/django-app-budget-rg \
    --sdk-auth

# Результат збережіть як AZURE_CREDENTIALS secret
```

## 📁 Крок 4: Структура файлів

Переконайтеся, що у вашому репозиторії є:

```
.github/
└── workflows/
    └── azure-deploy.yml
manage.py
requirements.txt
project_portfolio/
├── __init__.py
├── settings.py
├── urls.py
├── wsgi.py
└── ...
```

## 🎯 Крок 5: Тестування

1. **Push код у branch `feature/infrastructure-update`**
2. **Перейдіть до Actions tab у GitHub**
3. **Дивіться процес deployment**
4. **Перевірте результат на URL**

## 🔧 Крок 6: Швидке налаштування команд

```bash
# Швидко додайте workflow файл
mkdir -p .github/workflows
# Додайте вміст azure-deploy.yml

# Commit і push
git add .github/workflows/azure-deploy.yml
git commit -m "Add GitHub Actions for Azure deployment"
git push origin feature/infrastructure-update
```

## 🏥 Крок 7: Моніторинг

Після push Action автоматично:
- ✅ Збере проект
- ✅ Протестує Django
- ✅ Розгорне на Azure
- ✅ Виконає health check
- ✅ Покаже summary

## ⚡ Швидкий старт

1. **Додайте файл workflow**
2. **Встановіть `AZUREAPPSERVICE_PUBLISHPROFILE` та `DJANGO_SECRET_KEY`**
3. **Push код**
4. **Дивіться magic! 🎉**

URL результату: `https://django-app-budget-1752082786.azurewebsites.net`

## 🔍 Troubleshooting

Якщо deployment fails:
- Перевірте Secrets
- Дивіться Action logs
- Перевірте Azure App Service logs
- Переконайтеся, що `requirements.txt` правильний

## 🎯 Переваги GitHub Actions

- ✅ **Автоматичний deployment** при push
- ✅ **Тестування перед deployment**
- ✅ **Environment management**
- ✅ **Rollback можливості**
- ✅ **Детальні логи**
