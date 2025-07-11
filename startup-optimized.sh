#!/bin/bash
echo "🚀 Starting Django with PostgreSQL..."

# Exit on any error
set -e

# Перевіряємо підключення до БД
echo "🔍 Testing database connection..."
python manage.py dbshell --command="SELECT version();" || echo "⚠️ Database connection issue"

# Міграції
echo "📊 Running migrations..."
python manage.py migrate --noinput

# Створюємо superuser
echo "👤 Creating superuser..."
python manage.py shell << 'PYTHON_CODE'
import os
from django.contrib.auth import get_user_model
User = get_user_model()
admin_username = os.environ.get('DJANGO_ADMIN_USER', 'admin')
admin_email = os.environ.get('DJANGO_ADMIN_EMAIL', 'admin@company.com')
admin_password = os.environ.get('DJANGO_ADMIN_PASSWORD', 'SecureP@ssw0rd123!')
if not User.objects.filter(username=admin_username).exists():
    User.objects.create_superuser(admin_username, admin_email, admin_password)
    print(f"✅ Superuser '{admin_username}' created")
else:
    print(f"✅ Superuser '{admin_username}' already exists")
PYTHON_CODE

# Збираємо статичні файли
echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

# Force garbage collection before starting server
echo "🧹 Cleaning up memory..."
python -c "import gc; gc.collect(); print('✅ Memory cleanup completed')"

echo "✅ Setup complete! Starting memory-optimized server..."

# Memory-optimized Gunicorn configuration for B1 (1.75GB RAM)
exec gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 1 \
    --worker-class sync \
    --timeout 30 \
    --keepalive 2 \
    --max-requests 500 \
    --max-requests-jitter 50 \
    --preload-app \
    --worker-tmp-dir /dev/shm \
    --access-logfile - \
    --error-logfile - \
    --log-level warning \
    --worker-memory-limit 400000000 \
    project_portfolio.wsgi:application
