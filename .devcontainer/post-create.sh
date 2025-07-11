#!/bin/bash

# Встановлення залежностей
pip install -r requirements/development.txt

# Очікування готовності БД
echo "Очікування готовності PostgreSQL..."
while ! pg_isready -h db -p 5432 -U postgres; do
  sleep 1
done

# Застосування міграцій
python manage.py migrate

# Створення суперюзера (якщо потрібно)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Збір статичних файлів
python manage.py collectstatic --noinput

echo "🚀 Розробницьке середовище готове!"
