# simple_kv_test.py - Простий тест Key Vault з Azure CLI автентифікацією
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ClientAuthenticationError, ResourceNotFoundError

# Константи (замість kv_vars.py)
KEY_VAULT_URL = "https://django-app-keyvault.vault.azure.net/"
SECRET_NAME = "database-password"

def test_keyvault_simple():
    """Простий тест Key Vault"""
    
    print("🚀 Простий тест Azure Key Vault")
    print(f"🔗 URL: {KEY_VAULT_URL}")
    print(f"🔑 Секрет: {SECRET_NAME}")
    print()
    
    try:
        # Використання DefaultAzureCredential (працює з Azure CLI)
        print("🔑 Автентифікація через Azure CLI...")
        credential = DefaultAzureCredential()
        
        # Створення клієнта
        client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)
        print("✅ Клієнт створено")
        
        # Отримання секрету
        print(f"🔍 Отримання секрету '{SECRET_NAME}'...")
        secret = client.get_secret(SECRET_NAME)
        
        print("🎉 УСПІХ!")
        print(f"📝 Секрет: {secret.value}")
        print(f"🔢 Версія: {secret.properties.version}")
        
        return True
        
    except ClientAuthenticationError as e:
        print(f"❌ Помилка автентифікації: {e}")
        print("\n💡 Рішення:")
        print("1. Запустіть: az login")
        print("2. Перевірте права доступу до Key Vault")
        return False
        
    except ResourceNotFoundError as e:
        print(f"❌ Секрет не знайдено: {e}")
        print("\n💡 Перевірте чи існує секрет:")
        print(f"az keyvault secret show --vault-name django-app-keyvault --name {SECRET_NAME}")
        return False
        
    except Exception as e:
        print(f"❌ Загальна помилка: {e}")
        print(f"📊 Тип помилки: {type(e).__name__}")
        return False

if __name__ == "__main__":
    # Перевірка чи встановлені пакети
    try:
        import azure.keyvault.secrets
        import azure.identity
        print("✅ Необхідні пакети встановлені")
    except ImportError as e:
        print(f"❌ Відсутні пакети: {e}")
        print("💡 Встановіть: pip install azure-keyvault-secrets azure-identity")
        exit(1)
    
    # Запуск тесту
    success = test_keyvault_simple()
    
    if success:
        print("\n🎯 Наступні кроки:")
        print("1. Оновіть kv_vars.py з правильними credentials")
        print("2. Інтегруйте з Django settings")
        print("3. Додайте більше секретів до Key Vault")
    else:
        print("\n🔧 Діагностика:")
        print("1. az account show  # Перевірка входу")
        print("2. az keyvault list  # Перевірка доступу")
        print("3. az keyvault secret list --vault-name django-app-keyvault")
