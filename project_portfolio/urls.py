from django.contrib import admin
from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse
from django.shortcuts import render

# View для головної сторінки з template
def home_view(request):
    """Головна сторінка з index.html template"""
    context = {
        'debug_mode': settings.DEBUG,
        'secret_key_status': "✅ Налаштовано" if settings.SECRET_KEY else "❌ Відсутній",
        'database_engine': settings.DATABASES['default']['ENGINE'].split('.')[-1],
        'environment': 'GitHub Codespace',
        'key_vault_status': 'Fallback режим (development)',
        'email_backend': 'Console backend' if 'console' in settings.EMAIL_BACKEND else 'SMTP backend',
    }
    return render(request, 'index.html', context)

def health_check(request):
    """Health check endpoint"""
    from django.db import connection
    
    try:
        # Перевірка бази даних
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        db_status = "✅ OK"
    except Exception as e:
        db_status = f"❌ Error: {str(e)}"
    
    return HttpResponse(f"""
    <html>
    <head>
        <title>Health Check</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 50px; }}
            .status {{ margin: 10px 0; }}
            .ok {{ color: green; }}
            .error {{ color: red; }}
        </style>
    </head>
    <body>
        <h1>🏥 Health Check</h1>
        <div class="status">🌍 Server: <span class="ok">✅ Running</span></div>
        <div class="status">🗄️ Database: <span class="{'ok' if '✅' in db_status else 'error'}">{db_status}</span></div>
        <div class="status">⚙️ Django: <span class="ok">✅ {settings.DEBUG and 'DEBUG' or 'PRODUCTION'} Mode</span></div>
        <div class="status">📁 Templates: <span class="ok">✅ {len(settings.TEMPLATES[0]['DIRS'])} directories</span></div>
        <p><a href="/">← Назад на головну</a></p>
    </body>
    </html>
    """)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', home_view, name='home'),
    path('health/', health_check, name='health'),
]

# Статичні файли
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# Browser reload
if settings.DEBUG and 'django_browser_reload' in settings.INSTALLED_APPS:
    from django.urls import include
    urlpatterns += [
        path('__reload__/', include('django_browser_reload.urls')),
    ]
