// deployment/azure/main.bicep - Повна інфраструктура для Django додатка
@description('Environment name')
param environment string = 'dev'

@description('Location for all resources')  
param location string = resourceGroup().location

@description('App name prefix')
param appName string = 'django-app'

@description('Current user Object ID for Key Vault access')
param userObjectId string

@description('SKU for App Service Plan')
param appServiceSku string = environment == 'production' ? 'B1' : 'F1'

@description('PostgreSQL administrator login')
param postgresAdminUsername string = 'dbadmin'

@description('PostgreSQL administrator password')
@secure()
param postgresAdminPassword string

// Variables
var resourceSuffix = '${appName}-${environment}'
var keyVaultName = '${resourceSuffix}-kv'
var appServicePlanName = '${resourceSuffix}-plan'
var webAppName = '${resourceSuffix}-app'
var postgresServerName = '${resourceSuffix}-postgres'
var storageAccountName = replace('${resourceSuffix}storage', '-', '')

// Key Vault
module keyVault 'keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    environment: environment
    location: location
    appName: appName
    userObjectId: userObjectId
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServiceSku
    tier: appServiceSku == 'F1' ? 'Free' : 'Basic'
  }
  properties: {
    reserved: true // Linux
  }
  kind: 'linux'
  tags: {
    Environment: environment
    Project: appName
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: appServiceSku != 'F1'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      pythonVersion: '3.11'
      appSettings: [
        {
          name: 'DJANGO_SETTINGS_MODULE'
          value: 'config.settings.production'
        }
        {
          name: 'AZURE_KEY_VAULT_URL'
          value: keyVault.outputs.keyVaultUri
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '7'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Environment: environment
    Project: appName
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = if (environment != 'dev') {
  name: postgresServerName
  location: location
  sku: {
    name: environment == 'production' ? 'Standard_D2s_v3' : 'Standard_B1ms'
    tier: environment == 'production' ? 'GeneralPurpose' : 'Burstable'
  }
  properties: {
    version: '15'
    administratorLogin: postgresAdminUsername
    administratorLoginPassword: postgresAdminPassword
    storage: {
      storageSizeGB: environment == 'production' ? 128 : 32
    }
    backup: {
      backupRetentionDays: environment == 'production' ? 30 : 7
      geoRedundantBackup: environment == 'production' ? 'Enabled' : 'Disabled'
    }
    highAvailability: {
      mode: environment == 'production' ? 'ZoneRedundant' : 'Disabled'
    }
  }
  tags: {
    Environment: environment
    Project: appName
  }
}

// PostgreSQL Database
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = if (environment != 'dev') {
  parent: postgresServer
  name: '${appName}_${environment}'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: environment == 'production' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  tags: {
    Environment: environment
    Project: appName
  }
}

// Storage Container for media files
resource mediaContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/media'
  properties: {
    publicAccess: 'None'
  }
}

// Key Vault access policy for Web App managed identity
resource webAppKeyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
  dependsOn: [
    keyVault
  ]
}

// Outputs
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri
output postgresServerName string = environment != 'dev' ? postgresServer.name : 'Not deployed in dev'
output storageAccountName string = storageAccount.name
output managedIdentityPrincipalId string = webApp.identity.principalId

// Resource summary
output deploymentSummary object = {
  environment: environment
  appName: appName
  location: location
  resources: {
    webApp: webAppName
    keyVault: keyVault.outputs.keyVaultName
    postgres: environment != 'dev' ? postgresServer.name : 'dev-only'
    storage: storageAccount.name
  }
  urls: {
    webApp: 'https://${webApp.properties.defaultHostName}'
    keyVault: keyVault.outputs.keyVaultUri
  }
}
