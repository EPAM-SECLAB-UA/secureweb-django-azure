

```bash
 # Налаштуйте GitHub deployment замість ZIP
az webapp deployment source config \
    --name django-app-budget-1752082786 \
    --resource-group django-app-budget-rg \
    --repo-url https://github.com/EPAM-SECLAB-UA/secureweb-django-azure \
    --branch feature/infrastructure-update \
    --manual-integration
```
