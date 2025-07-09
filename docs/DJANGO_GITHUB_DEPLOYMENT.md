

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
