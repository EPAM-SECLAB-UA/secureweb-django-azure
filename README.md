
# 🚀 Portfolio Django Azure Deployment

[![Azure Deploy](https://img.shields.io/badge/Azure-Deploy-blue?logo=microsoftazure&logoColor=white)](https://github.com/Python-Development-Lab/portfolio-django-azure/actions)
[![Django](https://img.shields.io/badge/Django-4.2+-green?logo=django&logoColor=white)](https://djangoproject.com/)
[![Python](https://img.shields.io/badge/Python-3.11+-blue?logo=python&logoColor=white)](https://python.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Professional Django portfolio application with automated Azure deployment infrastructure**

## 🎯 Overview

This project provides a complete Django portfolio application with automated Azure infrastructure deployment. Features include cost-optimized deployment options, comprehensive cleanup utilities, and production-ready configuration.

## ✨ Features

### 🏗️ **Infrastructure Options**
- 💰 **Budget Deployment** (~$10-18/month) - Perfect for development and small projects
- 🏢 **Production Deployment** (~$100-120/month) - Enterprise-ready configuration
- 🧹 **Automated Cleanup** - Complete infrastructure removal utilities

### 🛠️ **Technical Stack**
- **Backend**: Django 4.2+ with PostgreSQL
- **Frontend**: Bootstrap-based responsive design
- **Cloud**: Azure App Service, PostgreSQL Flexible Server, Key Vault
- **DevOps**: GitHub Actions, automated deployment scripts
- **Monitoring**: Application Insights integration

### 📊 **Deployment Configurations**

| Configuration | Monthly Cost | Use Case | Resources |
|---------------|-------------|----------|-----------|
| 💰 **Budget** | $10-18 | Development, Testing, MVPs | F1 App Service + B1ms PostgreSQL |
| 🏢 **Production** | $100-120 | Business applications | B1+ App Service + D2ds_v4 PostgreSQL |

## 🚀 Quick Start

### 📋 Prerequisites

- **Azure CLI** installed and authenticated
- **Python 3.11+** 
- **Git** for version control
- **Active Azure subscription**

### ⚡ One-Click Deployment

#### **Budget Deployment (Recommended for testing)**
```bash
# Clone the repository
git clone https://github.com/Python-Development-Lab/portfolio-django-azure.git
cd portfolio-django-azure

# Run budget deployment
chmod +x budget-azure-deploy.sh
./budget-azure-deploy.sh
```

#### **Production Deployment**
```bash
# Run production deployment
chmod +x azure-infrastructure.sh
./azure-infrastructure.sh
```

### 📝 Manual Setup

1. **Clone and Setup**
   ```bash
   git clone https://github.com/Python-Development-Lab/portfolio-django-azure.git
   cd portfolio-django-azure
   
   # Install dependencies
   pip install -r requirements.txt
   ```

2. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Deploy to Azure**
   ```bash
   # Choose your deployment option
   ./budget-azure-deploy.sh        # For budget deployment
   ./azure-infrastructure.sh       # For production deployment
   ```

## 📁 Project Structure

```
portfolio-django-azure/
├── 📂 .devcontainer/           # Development container configuration
├── 📂 .github/workflows/       # GitHub Actions CI/CD
├── 📂 docs/                    # Documentation and guides
├── 📂 images/                  # Project screenshots and assets
├── 📂 project_portfolio/       # Main Django application
│   ├── 📄 settings/            # Environment-specific settings
│   ├── 📄 models.py            # Database models
│   ├── 📄 views.py             # Application views
│   └── 📄 urls.py              # URL routing
├── 🛠️ budget-azure-deploy.sh   # Budget deployment script
├── 🛠️ deploy-with-logs.sh      # Deployment with logging
├── 🔧 generate_secret_key.py   # Django secret key generator
├── 📋 requirements.txt         # Python dependencies
├── ⚙️ manage.py               # Django management
└── 📖 README.md               # This file
```

## 🔧 Configuration Options

### 💰 Budget Configuration
- **App Service**: F1 (Free tier)
- **Database**: PostgreSQL B1ms (1 vCore, 2GB RAM)
- **Storage**: Standard LRS
- **Monitoring**: Application Insights (free tier)

### 🏢 Production Configuration
- **App Service**: B1+ (Always On, custom domains)
- **Database**: PostgreSQL D2ds_v4 (2 vCore, 8GB RAM)
- **Storage**: Standard LRS with geo-redundancy
- **Monitoring**: Full Application Insights

## 📊 Cost Management

### 💡 **Cost Optimization Tips**
- Use **budget deployment** for development
- Enable **auto-shutdown** for non-production environments
- Monitor usage with **Azure Cost Management**
- Set up **billing alerts**

### 📈 **Scaling Options**
```bash
# Scale up App Service
az webapp update --resource-group myResourceGroup --name myApp --sku B2

# Scale PostgreSQL
az postgres flexible-server update --name myServer --sku-name Standard_D4ds_v4
```

## 🧹 Cleanup and Maintenance

### 🗑️ **Complete Infrastructure Removal**
```bash
# Interactive cleanup with confirmations
./cleanup-infrastructure.sh

# Preview what will be deleted
./cleanup-infrastructure.sh --dry-run

# Force cleanup (use with caution)
./cleanup-infrastructure.sh --force
```

### 📋 **Maintenance Commands**
```bash
# Check deployment status
./deploy-with-logs.sh budget-azure-deploy.sh

# Monitor application logs
az webapp log tail --name myApp --resource-group myResourceGroup

# Restart application
az webapp restart --name myApp --resource-group myResourceGroup
```

## 🔄 CI/CD Pipeline

### ⚙️ **GitHub Actions**
- **Automated testing** on pull requests
- **Staging deployment** on dev branch
- **Production deployment** on main branch
- **Infrastructure validation**

### 📝 **Deployment Workflow**
1. **Code Push** → GitHub
2. **Tests Run** → Automated validation
3. **Build** → Create deployment package
4. **Deploy** → Azure App Service
5. **Verify** → Health checks and monitoring

## 🛡️ Security Features

### 🔐 **Security Implementations**
- **Azure Key Vault** for secrets management
- **Managed Identity** for secure Azure resource access
- **HTTPS enforcement** with automatic redirects
- **Security headers** and CSRF protection
- **Environment variable** configuration

### 🚨 **Security Best Practices**
- Regular dependency updates
- Automated security scanning
- Database connection encryption
- Secure secret rotation

## 📈 Monitoring and Logging

### 📊 **Application Insights Integration**
- **Performance monitoring**
- **Error tracking and alerts**
- **Custom metrics and dashboards**
- **User analytics**

### 📝 **Logging Configuration**
```python
# Enhanced logging for production
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'azure': {
            'class': 'opencensus.ext.azure.log_exporter.AzureLogHandler',
            'connection_string': 'InstrumentationKey=...'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['azure'],
            'level': 'INFO',
        },
    },
}
```

## 🐛 Troubleshooting

### ❓ **Common Issues**

#### **Deployment Fails**
```bash
# Check Azure CLI authentication
az account show

# Verify resource group exists
az group exists --name django-app-budget-rg

# Check deployment logs
az webapp log tail --name myApp --resource-group myResourceGroup
```

#### **Database Connection Issues**
```bash
# Test database connectivity
az postgres flexible-server connect --name myServer --admin-user myUser

# Check firewall rules
az postgres flexible-server firewall-rule list --name myServer --resource-group myResourceGroup
```

#### **Application Not Starting**
```bash
# Check application settings
az webapp config appsettings list --name myApp --resource-group myResourceGroup

# Restart application
az webapp restart --name myApp --resource-group myResourceGroup

# SSH into container
az webapp ssh --name myApp --resource-group myResourceGroup
```

### 🔍 **Debug Mode**
```bash
# Run deployment with debug output
bash -x ./budget-azure-deploy.sh

# Enable verbose Azure CLI output
az --debug webapp create ...
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### 🛠️ **Development Setup**
```bash
# Fork and clone the repository
git clone https://github.com/your-username/portfolio-django-azure.git
cd portfolio-django-azure

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install development dependencies
pip install -r requirements.txt

# Set up pre-commit hooks
pre-commit install
```

### 📝 **Submitting Changes**
1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Make your changes and commit: `git commit -m 'Add amazing feature'`
3. Push to branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

## 📚 Documentation

- 📖 **[Deployment Guide](docs/DEPLOY.md)** - Detailed deployment instructions
- 🔧 **[Configuration Guide](docs/CONFIG.md)** - Environment configuration
- 🛠️ **[Development Guide](docs/DEVELOPMENT.md)** - Local development setup
- 🔒 **[Security Guide](docs/SECURITY.md)** - Security best practices

## 📧 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/Python-Development-Lab/portfolio-django-azure/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Python-Development-Lab/portfolio-django-azure/discussions)
- 📧 **Email**: [support@example.com](mailto:support@example.com)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Django Community** for the amazing framework
- **Microsoft Azure** for cloud infrastructure
- **Bootstrap** for responsive design components
- **All contributors** who help improve this project

---

## 🎯 Quick Links

| Action | Command | Description |
|--------|---------|-------------|
| 🚀 **Deploy Budget** | `./budget-azure-deploy.sh` | Deploy cost-effective version |
| 🏢 **Deploy Production** | `./azure-infrastructure.sh` | Deploy production-ready version |
| 🧹 **Cleanup** | `./cleanup-infrastructure.sh` | Remove all Azure resources |
| 📊 **Monitor** | `az webapp log tail --name myApp` | View application logs |
| 🔧 **Configure** | `az webapp config appsettings set` | Update app settings |

---

```markdown
## 🚀 Швидкий старт

### Налаштування Azure Key Vault:
```bash
./scripts/setup-keyvault.sh
```

