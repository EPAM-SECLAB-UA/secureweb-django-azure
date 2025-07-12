// deployment/azure/keyvault.bicep
@description('Environment name (dev, staging, production)')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App name prefix')
param appName string = 'django-app'

@description('Tenant ID for Key Vault access policies')
param tenantId string = subscription().tenantId

@description('Object ID of the user or service principal to grant access')
param userObjectId string

// Variables
var keyVaultName = '${appName}-${environment}-kv'
var resourceSuffix = '${appName}-${environment}'

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'production'
    enableRbacAuthorization: false
    publicNetworkAccess: 'Enabled'
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: userObjectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'backup'
            'restore'
            'recover'
          ]
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'backup'
            'restore'
            'recover'
          ]
          certificates: [
            'get'
            'list'
            'create'
            'delete'
            'backup'
            'restore'
            'recover'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: {
    Environment: environment
    Project: appName
    CreatedBy: 'Bicep'
    Purpose: 'Django Application Secrets'
  }
}

// Базові секрети (будуть замінені реальними значеннями)
resource secretDjangoKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'django-secret-key'
  properties: {
    value: 'temp-django-secret-key-replace-after-deployment'
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
  tags: {
    Purpose: 'Django SECRET_KEY'
    Environment: environment
  }
}

resource secretDatabasePassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'database-password'
  properties: {
    value: 'temp-database-password-replace-after-deployment'
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
  tags: {
    Purpose: 'Database Password'
    Environment: environment
  }
}

resource secretEmailPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'email-host-password'
  properties: {
    value: 'temp-email-password'
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
  tags: {
    Purpose: 'Email Host Password'
    Environment: environment
  }
}

// Outputs
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultId string = keyVault.id
output keyVaultResourceGroup string = resourceGroup().name

// Outputs для використання в інших templates
output keyVaultSecretUri string = '${keyVault.properties.vaultUri}secrets/'
output keyVaultReference object = {
  keyVault: {
    id: keyVault.id
  }
}

// Debug information
output deploymentInfo object = {
  keyVaultName: keyVaultName
  environment: environment
  location: location
  tenantId: tenantId
  userObjectId: userObjectId
}

