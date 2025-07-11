
Ось кілька варіантів назв для документації з Azure DevOps Deployment Guide:

## 🎯 **Рекомендовані назви:**

### **Основний варіант:**
```
azure-devops-django-deployment-guide.md
```

### **Альтернативні варіанти:**

**За функціональністю:**
- `django-azure-devops-pipeline-guide.md`
- `azure-devops-django-ci-cd-setup.md`
- `django-app-azure-devops-deployment.md`

**За структурою проекту:**
- `docs/deployment/azure-devops-deployment-guide.md`
- `docs/azure/devops-pipeline-setup.md`
- `docs/ci-cd/azure-devops-django-guide.md`

**За категоріями:**
- `azure-devops-django-automation-guide.md`
- `django-azure-devops-complete-guide.md`
- `azure-devops-deployment-playbook.md`

## 📁 **Рекомендована структура папок:**

```
project-root/
├── docs/
│   ├── deployment/
│   │   ├── github-actions-deployment.md
│   │   ├── azure-devops-django-deployment-guide.md  ← ЦЕЙ ФАЙЛ
│   │   └── manual-deployment-guide.md
│   ├── azure/
│   │   ├── azure-devops-pipeline-setup.md  ← АБО ЦЕЙ
│   │   ├── service-connections-guide.md
│   │   └── log-analytics-queries.md
│   ├── ci-cd/
│   │   ├── azure-devops-setup.md
│   │   ├── pipeline-troubleshooting.md
│   │   └── deployment-strategies.md
│   └── README.md
```

## 🏷️ **Найкращий варіант:**

**`docs/deployment/azure-devops-django-deployment-guide.md`**

**Чому саме цей:**
- ✅ Зрозуміло що це Azure DevOps guide
- ✅ Вказує на Django application
- ✅ Слово "deployment" показує призначення
- ✅ Категоризовано в deployment папці
- ✅ Легко знайти та згадати
- ✅ Масштабується для інших deployment guides

## 📋 **Рекомендована структура файлу:**

```markdown
# Azure DevOps Deployment Guide for Django App

## Overview
Complete guide for deploying Django application using Azure DevOps pipelines.

## Prerequisites
### Azure Requirements
### GitHub Repository Setup
### Django Project Structure

## Step 1: Azure DevOps Project Setup
### Creating Project
### GitHub Integration
### Repository Connection

## Step 2: Service Connections
### Azure Resource Manager
### Authentication Methods
### Troubleshooting

## Step 3: Pipeline Configuration
### YAML Structure
### Build Stage
### Deploy Stage

## Step 4: Variables and Secrets
### Variable Groups
### Environment Variables
### Security Best Practices

## Step 5: Environment Setup
### Production Environment
### Approval Gates
### Monitoring

## Advanced Features
### Multi-stage Pipelines
### Template Usage
### Security Scanning

## Troubleshooting
### Common Issues
### Service Connection Problems
### Pipeline Failures

## Best Practices
### Security
### Performance
### Maintenance
```

## 🔍 **Альтернативи для різних контекстів:**

**Якщо фокус на CI/CD:**
```
azure-devops-ci-cd-django-guide.md
```

**Якщо частина більшого automation suite:**
```
django-automation-azure-devops.md
```

**Якщо enterprise documentation:**
```
enterprise-azure-devops-django-deployment.md
```

**Якщо порівняльна документація:**
```
azure-devops-vs-github-actions-django.md
```

## 🎯 **Спеціалізовані назви:**

**Для step-by-step tutorial:**
```
azure-devops-django-tutorial.md
```

**Для quick start:**
```
azure-devops-django-quickstart.md
```

**Для troubleshooting focus:**
```
azure-devops-django-troubleshooting.md
```

**Для enterprise environments:**
```
azure-devops-django-enterprise-guide.md
```

## 📊 **Metadata для файлу:**

```markdown
---
title: "Azure DevOps Deployment Guide for Django App"
description: "Complete guide for setting up CI/CD pipeline for Django applications using Azure DevOps"
tags: ["azure-devops", "django", "deployment", "ci-cd", "python"]
author: "Vitalii Shevchuk"
created: "2025-07-11"
updated: "2025-07-11"
version: "1.0"
---
```

**Найпрактичніший варіант:** `docs/deployment/azure-devops-django-deployment-guide.md` 🎯

---------------------------------------------------------------------------------------------------------------------------------

# 🚀 **Azure DevOps Deployment Guide для Django App**

Ось повний гід по deploy Django додатку з GitHub репозиторію в Azure DevOps!

## 🎯 **Ключові переваги Azure DevOps:**

### **🔧 vs GitHub Actions:**
- **Better Azure integration** - native Azure services support
- **Enterprise features** - approvals, gates, environments
- **Advanced variables** - variable groups, secrets management
- **Multi-stage pipelines** з dependencies
- **Built-in testing** frameworks
- **Template system** для reusability

## 📋 **Основні кроки:**

### **1. Project Setup:**
- Створити Azure DevOps project
- Підключити GitHub repo: `EPAM-SECLAB-UA/secureweb-django-azure`
- Branch: `feature/infrastructure-update`

### **2. Service Connection:**
- Azure Resource Manager connection
- Scope: `django-app-budget-rg` resource group
- Auto або manual service principal

### **3. Pipeline YAML:**
- **Build stage:** Python 3.11, dependencies, validation
- **Deploy stage:** Azure Web App deployment з memory optimization
- **Health checks:** automated verification

### **4. Variables Management:**
- **Variable group:** `Django-App-Config`
- **Secrets:** DJANGO_SECRET_KEY, DB_PASSWORD, etc.
- **Pipeline variables:** webAppName, resourceGroup

## 🔑 **Key Features в pipeline:**

### **Memory Optimization:**
```yaml
startUpCommand: 'bash startup-optimized.sh'
```

### **Automated Configuration:**
```yaml
az webapp config appsettings set \
  --settings DJANGO_SETTINGS_MODULE="project_portfolio.settings" \
           SECRET_KEY="$(DJANGO_SECRET_KEY)" \
           DEBUG="False"
```

### **Health Verification:**
```yaml
# Automated health checks post-deployment
curl https://django-app-budget-1752082786.azurewebsites.net
```

## 🎯 **Expected Results:**

- ✅ **Fully automated** deployment process
- ✅ **Memory optimization** (1 worker, 30s timeout, 400MB limit)
- ✅ **OOM kills elimination**
- ✅ **Enterprise-grade** pipeline з approvals
- ✅ **Rollback capability**
- ✅ **Complete traceability**

**Azure DevOps pipeline забезпечить професійний enterprise-level deployment для вашого Django проекту!** 🚀

Почати з створення project в dev.azure.com та підключення GitHub repo?

----------------------------------------------------------------------------------------------------------------------------------------------







# 🚀 Azure DevOps Deployment Guide for Django App

## 📋 **Огляд проекту**

**Repository:** https://github.com/EPAM-SECLAB-UA/secureweb-django-azure  
**Branch:** feature/infrastructure-update  
**Target:** Azure App Service (django-app-budget-1752082786)  
**Tech Stack:** Django 5.2.2, Python 3.11, PostgreSQL, Gunicorn  

## 🎯 **Step 1: Налаштування Azure DevOps Project**

### **1.1 Створення нового проекту**
```
1. 🌐 Перейти до dev.azure.com
2. ➕ New project
3. 📝 Project name: "SecureWeb Django Azure"
4. 👁️ Visibility: Private
5. 🆕 Create
```

### **1.2 Підключення до GitHub репозиторію**
```
1. 📊 Pipelines → Create Pipeline
2. 🔗 GitHub (YAML)
3. 🔐 Authorize Azure Pipelines
4. 📂 Select repository: EPAM-SECLAB-UA/secureweb-django-azure
5. 🌿 Configure existing Azure Pipelines YAML file
6. 📝 Path: /azure-pipelines.yml (створимо далі)
```

## 🔧 **Step 2: Створення Azure Pipeline YAML**

### **2.1 Створити файл `azure-pipelines.yml` в root проекту:**

```yaml
# Azure DevOps Pipeline for Django App Deployment
trigger:
  branches:
    include:
    - main
    - feature/infrastructure-update

variables:
  # Build Variables
  pythonVersion: '3.11'
  azureServiceConnection: 'Azure-Connection'
  webAppName: 'django-app-budget-1752082786'
  resourceGroupName: 'django-app-budget-rg'
  
  # Build configuration
  buildConfiguration: 'Release'
  vmImageName: 'ubuntu-latest'

stages:
- stage: Build
  displayName: 'Build Django Application'
  jobs:
  - job: Build
    displayName: 'Build Job'
    pool:
      vmImage: $(vmImageName)
    
    steps:
    - task: UsePythonVersion@0
      displayName: 'Use Python $(pythonVersion)'
      inputs:
        versionSpec: '$(pythonVersion)'
        addToPath: true
        architecture: 'x64'
    
    - script: |
        echo "🐍 Python version:"
        python --version
        echo "📦 Installing dependencies..."
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Install dependencies'
    
    - script: |
        echo "🧪 Running Django validation..."
        python -c "
        import os
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project_portfolio.settings')
        import django
        django.setup()
        print('✅ Django configuration valid')
        "
      displayName: 'Validate Django Configuration'
      env:
        SECRET_KEY: 'azure-devops-test-key'
        DEBUG: 'False'
    
    - script: |
        echo "📝 Preparing startup script..."
        chmod +x startup-optimized.sh
        ls -la startup-optimized.sh
      displayName: 'Prepare Startup Script'
    
    - script: |
        echo "🧹 Cleaning build artifacts..."
        find . -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        find . -name "*.pyc" -delete
        find . -name "*.pyo" -delete
        
        # Remove development files
        rm -rf .git/ .vscode/ .devcontainer/ docs/ tests/ *.log .env* || true
        
        echo "✅ Build preparation completed"
        echo "📋 Final package contents:"
        ls -la
      displayName: 'Prepare Deployment Package'
    
    - task: ArchiveFiles@2
      displayName: 'Archive Application'
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: zip
        archiveFile: $(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip
        replaceExistingArchive: true
    
    - task: PublishBuildArtifacts@1
      displayName: 'Upload Artifacts'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'django-app'
        publishLocation: 'Container'

- stage: Deploy
  displayName: 'Deploy to Azure App Service'
  dependsOn: Build
  condition: succeeded()
  
  jobs:
  - deployment: Deploy
    displayName: 'Deploy Django App'
    environment: 'production'
    pool:
      vmImage: $(vmImageName)
    
    strategy:
      runOnce:
        deploy:
          steps:
          - task: DownloadBuildArtifacts@0
            displayName: 'Download Artifacts'
            inputs:
              buildType: 'current'
              downloadType: 'single'
              artifactName: 'django-app'
              downloadPath: '$(System.ArtifactsDirectory)'
          
          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              appType: 'webAppLinux'
              appName: '$(webAppName)'
              package: '$(System.ArtifactsDirectory)/django-app/$(Build.BuildId).zip'
              runtimeStack: 'PYTHON|3.11'
              startUpCommand: 'bash startup-optimized.sh'
          
          - task: AzureCLI@2
            displayName: 'Configure App Settings'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "⚙️ Configuring App Service settings..."
                
                az webapp config appsettings set \
                  --resource-group $(resourceGroupName) \
                  --name $(webAppName) \
                  --settings \
                    DJANGO_SETTINGS_MODULE="project_portfolio.settings" \
                    SECRET_KEY="$(DJANGO_SECRET_KEY)" \
                    DEBUG="False" \
                    DJANGO_ALLOWED_HOSTS="$(webAppName).azurewebsites.net,.azurewebsites.net,localhost" \
                    DB_NAME="$(DB_NAME)" \
                    DB_USER="$(DB_USER)" \
                    DB_PASSWORD="$(DB_PASSWORD)" \
                    DB_HOST="$(DB_HOST)" \
                    DB_PORT="5432" \
                    PYTHONPATH="/home/site/wwwroot"
                
                echo "🚀 Setting startup command..."
                az webapp config set \
                  --resource-group $(resourceGroupName) \
                  --name $(webAppName) \
                  --startup-file "bash startup-optimized.sh"
                
                echo "✅ Configuration completed!"
          
          - task: AzureCLI@2
            displayName: 'Restart App Service'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "🔄 Restarting App Service..."
                az webapp restart \
                  --resource-group $(resourceGroupName) \
                  --name $(webAppName)
                echo "✅ App Service restarted!"
          
          - script: |
              echo "🏥 Testing application health..."
              sleep 60
              
              APP_URL="https://$(webAppName).azurewebsites.net"
              
              for i in {1..10}; do
                echo "🔍 Health check attempt $i/10"
                
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL" || echo "000")
                
                if [ "$HTTP_STATUS" = "200" ]; then
                  echo "✅ Application is healthy!"
                  echo "🌐 URL: $APP_URL"
                  echo "🛡️ Admin: $APP_URL/admin/"
                  exit 0
                fi
                
                if [ $i -lt 10 ]; then
                  echo "⏳ Waiting 30 seconds..."
                  sleep 30
                fi
              done
              
              echo "⚠️ Health check completed with warnings"
              exit 1
            displayName: 'Health Check'
            continueOnError: true
```

## 🔐 **Step 3: Налаштування Service Connections**

### **3.1 Створення Azure Service Connection**
```
1. 🔧 Project Settings → Service connections
2. ➕ New service connection
3. 🌐 Azure Resource Manager
4. 🔐 Service principal (automatic)
5. 📋 Subscription: Pay-As-You-Go-Student02
6. 📂 Resource group: django-app-budget-rg
7. 📝 Service connection name: Azure-Connection
8. ✅ Grant access permission to all pipelines
9. 💾 Save
```

### **3.2 Альтернативний метод (Manual Service Principal)**
```
1. 🔧 Service principal (manual)
2. 📋 Subscription ID: f7dc8823-4f06-4346-9de0-badbe6273a54
3. 📝 Service Principal Details:
   - Client ID: [з Azure Portal App Registration]
   - Client Secret: [з Azure Portal]
   - Tenant ID: [з Azure Portal]
4. 📝 Service connection name: Azure-Connection
5. ✅ Verify and save
```

## 🔑 **Step 4: Налаштування Pipeline Variables**

### **4.1 Pipeline Variables (Library)**
```
1. 📊 Pipelines → Library
2. ➕ Variable group
3. 📝 Name: "Django-App-Config"
4. ➕ Add variables:

Variable Name              | Value                                | Secret
──────────────────────────────────────────────────────────────────
DJANGO_SECRET_KEY         | your-django-secret-key               | ✅
DB_NAME                   | your-database-name                   | ❌
DB_USER                   | your-database-user                   | ❌
DB_PASSWORD               | your-database-password               | ✅
DB_HOST                   | your-db-host.postgres.database.azure.com | ❌
DJANGO_ADMIN_PASSWORD     | your-admin-password                  | ✅

5. 💾 Save
6. 🔐 Pipeline permissions → Permit all pipelines
```

### **4.2 Update Pipeline to use Variable Group**
```yaml
# Додати в azure-pipelines.yml на початку:
variables:
- group: Django-App-Config  # Reference to variable group
- name: pythonVersion
  value: '3.11'
- name: azureServiceConnection
  value: 'Azure-Connection'
# ... rest of variables
```

## 🏢 **Step 5: Налаштування Environments**

### **5.1 Створення Production Environment**
```
1. 📊 Pipelines → Environments
2. ➕ New environment
3. 📝 Name: production
4. 📋 Description: "Production environment for Django app"
5. 🎯 Resource: None (we'll use Azure App Service directly)
6. 🆕 Create
```

### **5.2 Налаштування Approvals (Optional)**
```
1. 📊 Environment: production
2. ⚙️ More actions → Approvals and checks
3. ➕ Approvals
4. 👤 Approvers: [your email]
5. 📋 Instructions: "Review deployment before production"
6. 🆕 Create
```

## 🔧 **Step 6: Advanced Pipeline Features**

### **6.1 Multi-Stage Pipeline з Testing**
```yaml
stages:
- stage: Test
  displayName: 'Run Tests'
  jobs:
  - job: UnitTests
    displayName: 'Unit Tests'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '3.11'
    - script: |
        pip install -r requirements.txt
        python manage.py test
      displayName: 'Run Django Tests'
      env:
        SECRET_KEY: 'test-secret-key'
        DEBUG: 'True'

- stage: SecurityScan
  displayName: 'Security Scanning'
  jobs:
  - job: SecurityScan
    displayName: 'Security Analysis'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - script: |
        pip install bandit safety
        bandit -r . -f json -o bandit-report.json || true
        safety check --json > safety-report.json || true
      displayName: 'Security Scan'
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-*.xml'

- stage: Build
  displayName: 'Build Application'
  dependsOn: 
  - Test
  - SecurityScan
  # ... build stage як вище
```

### **6.2 Parallel Deployments для різних environments**
```yaml
- stage: DeployStaging
  displayName: 'Deploy to Staging'
  dependsOn: Build
  jobs:
  - deployment: DeployStaging
    environment: 'staging'
    variables:
      webAppName: 'django-app-staging'
    # ... deployment steps

- stage: DeployProduction
  displayName: 'Deploy to Production'
  dependsOn: DeployStaging
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployProduction
    environment: 'production'
    variables:
      webAppName: 'django-app-budget-1752082786'
    # ... deployment steps
```

## 📊 **Step 7: Monitoring та Reporting**

### **7.1 Test Results Publishing**
```yaml
- task: PublishTestResults@2
  displayName: 'Publish Test Results'
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results.xml'
    mergeTestResults: true
    testRunTitle: 'Django Unit Tests'
  condition: always()

- task: PublishCodeCoverageResults@1
  displayName: 'Publish Coverage'
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '**/coverage.xml'
```

### **7.2 Build Artifacts Management**
```yaml
- task: PublishBuildArtifacts@1
  displayName: 'Publish Deployment Scripts'
  inputs:
    PathtoPublish: 'deployment/'
    ArtifactName: 'deployment-scripts'

- task: PublishBuildArtifacts@1
  displayName: 'Publish Configuration'
  inputs:
    PathtoPublish: 'config/'
    ArtifactName: 'configuration'
```

## 🚀 **Step 8: Запуск та тестування Pipeline**

### **8.1 Manual Pipeline Run**
```
1. 📊 Pipelines → [Your Pipeline]
2. ▶️ Run pipeline
3. 🌿 Branch: feature/infrastructure-update
4. 🔧 Variables: (перевірити що всі налаштовані)
5. 🚀 Run
```

### **8.2 Моніторинг виконання**
```
1. 📊 Watch pipeline execution in real-time
2. 📋 Check logs for each stage
3. 🔍 Monitor deployment progress
4. 🏥 Verify health checks
5. 🌐 Test application URL
```

## 🛠️ **Step 9: Troubleshooting та Best Practices**

### **9.1 Common Issues та рішення**

#### **Service Connection Issues:**
```yaml
# У pipeline YAML, перевірити:
azureSubscription: '$(azureServiceConnection)'  # Правильна назва

# Або використати exact name:
azureSubscription: 'Azure-Connection'
```

#### **Variable Issues:**
```yaml
# Перевірити змінні в runtime:
- script: |
    echo "Secret key length: ${#DJANGO_SECRET_KEY}"
    echo "DB Host: $DB_HOST"
    echo "Web App: $(webAppName)"
  displayName: 'Debug Variables'
  env:
    DJANGO_SECRET_KEY: $(DJANGO_SECRET_KEY)
    DB_HOST: $(DB_HOST)
```

#### **Memory Optimization Verification:**
```yaml
- task: AzureCLI@2
  displayName: 'Verify Memory Settings'
  inputs:
    azureSubscription: '$(azureServiceConnection)'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      STARTUP_CMD=$(az webapp config show \
        --resource-group $(resourceGroupName) \
        --name $(webAppName) \
        --query "appCommandLine" -o tsv)
      
      echo "Current startup command: $STARTUP_CMD"
      
      if [[ "$STARTUP_CMD" == *"startup-optimized.sh"* ]]; then
        echo "✅ Memory optimization active!"
      else
        echo "⚠️ Memory optimization may not be configured"
      fi
```

### **9.2 Pipeline Best Practices**

#### **Resource Management:**
```yaml
# Use pipeline caching
- task: Cache@2
  inputs:
    key: 'python | "$(Agent.OS)" | requirements.txt'
    restoreKeys: |
      python | "$(Agent.OS)"
    path: $(pip_cache_dir)
  displayName: 'Cache pip packages'

# Parallel jobs
strategy:
  parallel: 2
```

#### **Security Best Practices:**
```yaml
# Never expose secrets in logs
- script: |
    echo "DB Host: $(DB_HOST)"
    # echo "DB Password: $(DB_PASSWORD)"  # ❌ Never do this
  displayName: 'Debug (Safe)'
```

## 📋 **Step 10: Pipeline Templates (Advanced)**

### **10.1 Створити template для reusability**

**File: `templates/django-deploy.yml`**
```yaml
parameters:
- name: webAppName
  type: string
- name: resourceGroupName
  type: string
- name: environment
  type: string

steps:
- task: AzureWebApp@1
  displayName: 'Deploy to ${{ parameters.environment }}'
  inputs:
    azureSubscription: '$(azureServiceConnection)'
    appType: 'webAppLinux'
    appName: '${{ parameters.webAppName }}'
    package: '$(System.ArtifactsDirectory)/django-app/$(Build.BuildId).zip'
    runtimeStack: 'PYTHON|3.11'
    startUpCommand: 'bash startup-optimized.sh'

- template: configure-app-settings.yml
  parameters:
    webAppName: '${{ parameters.webAppName }}'
    resourceGroupName: '${{ parameters.resourceGroupName }}'
```

### **10.2 Use template в main pipeline**
```yaml
- stage: Deploy
  jobs:
  - deployment: Deploy
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - template: templates/django-deploy.yml
            parameters:
              webAppName: '$(webAppName)'
              resourceGroupName: '$(resourceGroupName)'
              environment: 'production'
```

## 🎯 **Результат та переваги Azure DevOps**

### **✅ Переваги Azure DevOps vs GitHub Actions:**
- **Better integration** з Azure services
- **More powerful** variable management
- **Enterprise features** (approvals, gates)
- **Built-in testing** frameworks
- **Advanced reporting** та analytics
- **Multi-stage** pipelines з dependencies
- **Template system** для reusability

### **📊 Expected Results:**
- **Automated deployment** з feature/infrastructure-update branch
- **Memory optimization** automatic configuration
- **Health verification** включено в pipeline
- **Full traceability** всіх deployments
- **Rollback capability** через Azure DevOps

**Цей Azure DevOps pipeline забезпечить повністю автоматизований та надійний deployment вашого Django додатку!** 🚀
