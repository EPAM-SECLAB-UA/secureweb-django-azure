from django.contrib import admin
from django.contrib.auth.models import User, Group

# Кастомізація admin site
admin.site.site_header = "SecureWeb Django Admin"
admin.site.site_title = "EPAM SecLab Admin"
admin.site.index_title = "Welcome to Admin panel"
