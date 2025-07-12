# kv_vars.py - НІКОЛИ НЕ КОМІТЬСЯ У GIT!
import os

# Azure AD Authentication
AZURE_CLIENT_ID = "12345678-1234-1234-1234-123456789abc"      # Application ID
AZURE_CLIENT_SECRET = "abcdef123456"                          # Key/Token
AZURE_TENANT_ID = "87654321-4321-4321-4321-210987654321"     # Tenant ID

# Key Vault Configuration  
AZURE_KEY_VAULT_URL = "https://my-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"
SECRET_VERSION = "1.0"  # Опціонально, якщо порожньо - береться остання версія
