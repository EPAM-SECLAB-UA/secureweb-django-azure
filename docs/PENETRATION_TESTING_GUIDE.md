

```

DisallowedHost at /
Invalid HTTP_HOST header: 'django-app-budget-1752082786.azurewebsites.net'. You may need to add 'django-app-budget-1752082786.azurewebsites.net' to ALLOWED_HOSTS.
Request Method:	GET
Request URL:	http://django-app-budget-1752082786.azurewebsites.net/
Django Version:	5.2.4
Exception Type:	DisallowedHost
Exception Value:	
Invalid HTTP_HOST header: 'django-app-budget-1752082786.azurewebsites.net'. You may need to add 'django-app-budget-1752082786.azurewebsites.net' to ALLOWED_HOSTS.
Exception Location:	/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages/django/http/request.py, line 202, in get_host
Raised during:	project_portfolio.core.views.index
Python Executable:	/opt/python/3.11.12/bin/python3.11
Python Version:	3.11.12
Python Path:	
['/tmp/8ddbf6da509ab87',
 '/opt/python/3.11.12/bin',
 '/home/site/wwwroot',
 '/opt/startup/app_logs',
 '/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages',
 '/opt/python/3.11.12/lib/python311.zip',
 '/opt/python/3.11.12/lib/python3.11',
 '/opt/python/3.11.12/lib/python3.11/lib-dynload',
 '/opt/python/3.11.12/lib/python3.11/site-packages']
Server time:	Thu, 10 Jul 2025 05:17:07 +0000
Traceback Switch to copy-and-paste view
/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages/django/core/handlers/exception.py, line 55, in inner
                response = get_response(request)
                               ^^^^^^^^^^^^^^^^^^^^^ …
Local vars
/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages/django/utils/deprecation.py, line 119, in __call__
            response = self.process_request(request)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ …
Local vars
/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages/django/middleware/common.py, line 48, in process_request
        host = request.get_host()
                   ^^^^^^^^^^^^^^^^^^ …
Local vars
/tmp/8ddbf6da509ab87/antenv/lib/python3.11/site-packages/django/http/request.py, line 202, in get_host
            raise DisallowedHost(msg)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^ …
Local vars
Request information
USER
[unable to retrieve the current user]

GET
No GET data

POST
No POST data

FILES
No FILES data

COOKIES
Variable	Value
ARRAffinity	
'3d899f120bebb3ad80d2b179924bba3aeb46f74b5e67108ec6828fde3874bf24'
ARRAffinitySameSite	
'3d899f120bebb3ad80d2b179924bba3aeb46f74b5e67108ec6828fde3874bf24'
META
Variable	Value
HTTP_ACCEPT	
'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
HTTP_ACCEPT_ENCODING	
'gzip, deflate, br, zstd'
HTTP_ACCEPT_LANGUAGE	
'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7'
HTTP_CLIENT_IP	
'91.229.123.182:59753'
HTTP_COOKIE	
'********************'
HTTP_DISGUISED_HOST	
'django-app-budget-1752082786.azurewebsites.net'
HTTP_HOST	
'django-app-budget-1752082786.azurewebsites.net'
HTTP_MAX_FORWARDS	
'10'
HTTP_PRIORITY	
'u=0, i'
HTTP_REFERER	
'https://github.com/EPAM-SECLAB-UA/secureweb-django-azure/actions/runs/16186440394'
HTTP_SEC_CH_UA	
'"Google Chrome";v="137", "Chromium";v="137", "Not/A)Brand";v="24"'
HTTP_SEC_CH_UA_MOBILE	
'?0'
HTTP_SEC_CH_UA_PLATFORM	
'"Windows"'
HTTP_SEC_FETCH_DEST	
'document'
HTTP_SEC_FETCH_MODE	
'navigate'
HTTP_SEC_FETCH_SITE	
'cross-site'
HTTP_SEC_FETCH_USER	
'?1'
HTTP_USER_AGENT	
('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like '
 'Gecko) Chrome/137.0.0.0 Safari/537.36')
HTTP_WAS_DEFAULT_HOSTNAME	
'django-app-budget-1752082786.azurewebsites.net'
HTTP_X_APPSERVICE_PROTO	
'https'
HTTP_X_ARR_LOG_ID	
'266787d8-8199-45ce-aebb-533b0305f3e2'
HTTP_X_ARR_SSL	
('2048|256|CN=Microsoft Azure RSA TLS Issuing CA 08, O=Microsoft Corporation, '
 'C=US|CN=*.azurewebsites.net, O=Microsoft Corporation, L=Redmond, S=WA, C=US')
HTTP_X_CLIENT_IP	
'91.229.123.182'
HTTP_X_CLIENT_PORT	
'59753'
HTTP_X_FORWARDED_FOR	
'91.229.123.182:59753'
HTTP_X_FORWARDED_PROTO	
'https'
HTTP_X_FORWARDED_TLSVERSION	
'1.3'
HTTP_X_ORIGINAL_URL	
'/'
HTTP_X_SITE_DEPLOYMENT_ID	
'django-app-budget-1752082786'
HTTP_X_WAWS_UNENCODED_URL	
'/'
PATH_INFO	
'/'
QUERY_STRING	
''
RAW_URI	
'/'
REMOTE_ADDR	
'169.254.129.1'
REMOTE_PORT	
'53957'
REQUEST_METHOD	
'GET'
SCRIPT_NAME	
''
SERVER_NAME	
'0.0.0.0'
SERVER_PORT	
'8000'
SERVER_PROTOCOL	
'HTTP/1.1'
SERVER_SOFTWARE	
'gunicorn/23.0.0'
gunicorn.socket	
<socket.socket fd=9, family=2, type=1, proto=0, laddr=('169.254.129.6', 8000), raddr=('169.254.129.1', 53957)>
wsgi.errors	
<gunicorn.http.wsgi.WSGIErrorsWrapper object at 0x7de9543c4130>
wsgi.file_wrapper	
<class 'gunicorn.http.wsgi.FileWrapper'>
wsgi.input	
<gunicorn.http.body.Body object at 0x7de9543a2190>
wsgi.input_terminated	
True
wsgi.multiprocess	
False
wsgi.multithread	
False
wsgi.run_once	
False
wsgi.url_scheme	
'http'
wsgi.version	
(1, 0)
Settings
Using settings module project_portfolio.settings
Setting	Value
ABSOLUTE_URL_OVERRIDES	
{}
ADMINS	
[]
ALLOWED_HOSTS	
['localhost']
APPEND_SLASH	
True
AUTHENTICATION_BACKENDS	
'********************'
AUTH_PASSWORD_VALIDATORS	
'********************'
AUTH_USER_MODEL	
'********************'
BASE_DIR	
PosixPath('/tmp/8ddbf6da509ab87')
CACHES	
{'default': {'BACKEND': 'django.core.cache.backends.locmem.LocMemCache'}}
CACHE_MIDDLEWARE_ALIAS	
'default'
CACHE_MIDDLEWARE_KEY_PREFIX	
'********************'
CACHE_MIDDLEWARE_SECONDS	
600
CSRF_COOKIE_AGE	
31449600
CSRF_COOKIE_DOMAIN	
None
CSRF_COOKIE_HTTPONLY	
False
CSRF_COOKIE_NAME	
'csrftoken'
CSRF_COOKIE_PATH	
'/'
CSRF_COOKIE_SAMESITE	
'Lax'
CSRF_COOKIE_SECURE	
False
CSRF_FAILURE_VIEW	
'django.views.csrf.csrf_failure'
CSRF_HEADER_NAME	
'HTTP_X_CSRFTOKEN'
CSRF_TRUSTED_ORIGINS	
[]
CSRF_USE_SESSIONS	
False
DATABASES	
{'default': {'ATOMIC_REQUESTS': False,
             'AUTOCOMMIT': True,
             'CONN_HEALTH_CHECKS': False,
             'CONN_MAX_AGE': 0,
             'ENGINE': 'django.db.backends.sqlite3',
             'HOST': '',
             'NAME': PosixPath('/tmp/8ddbf6da509ab87/db.sqlite3'),
             'OPTIONS': {},
             'PASSWORD': '********************',
             'PORT': '',
             'TEST': {'CHARSET': None,
                      'COLLATION': None,
                      'MIGRATE': True,
                      'MIRROR': None,
                      'NAME': None},
             'TIME_ZONE': None,
             'USER': ''}}
DATABASE_ROUTERS	
[]
DATA_UPLOAD_MAX_MEMORY_SIZE	
2621440
DATA_UPLOAD_MAX_NUMBER_FIELDS	
1000
DATA_UPLOAD_MAX_NUMBER_FILES	
100
DATETIME_FORMAT	
'N j, Y, P'
DATETIME_INPUT_FORMATS	
['%Y-%m-%d %H:%M:%S',
 '%Y-%m-%d %H:%M:%S.%f',
 '%Y-%m-%d %H:%M',
 '%m/%d/%Y %H:%M:%S',
 '%m/%d/%Y %H:%M:%S.%f',
 '%m/%d/%Y %H:%M',
 '%m/%d/%y %H:%M:%S',
 '%m/%d/%y %H:%M:%S.%f',
 '%m/%d/%y %H:%M']
DATE_FORMAT	
'N j, Y'
DATE_INPUT_FORMATS	
['%Y-%m-%d',
 '%m/%d/%Y',
 '%m/%d/%y',
 '%b %d %Y',
 '%b %d, %Y',
 '%d %b %Y',
 '%d %b, %Y',
 '%B %d %Y',
 '%B %d, %Y',
 '%d %B %Y',
 '%d %B, %Y']
DEBUG	
'False'
DEBUG_PROPAGATE_EXCEPTIONS	
False
DECIMAL_SEPARATOR	
'.'
DEFAULT_AUTO_FIELD	
'django.db.models.BigAutoField'
DEFAULT_CHARSET	
'utf-8'
DEFAULT_EXCEPTION_REPORTER	
'django.views.debug.ExceptionReporter'
DEFAULT_EXCEPTION_REPORTER_FILTER	
'django.views.debug.SafeExceptionReporterFilter'
DEFAULT_FROM_EMAIL	
'webmaster@localhost'
DEFAULT_INDEX_TABLESPACE	
''
DEFAULT_TABLESPACE	
''
DISALLOWED_USER_AGENTS	
[]
EMAIL_BACKEND	
'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST	
'localhost'
EMAIL_HOST_PASSWORD	
'********************'
EMAIL_HOST_USER	
''
EMAIL_PORT	
25
EMAIL_SSL_CERTFILE	
None
EMAIL_SSL_KEYFILE	
'********************'
EMAIL_SUBJECT_PREFIX	
'[Django] '
EMAIL_TIMEOUT	
None
EMAIL_USE_LOCALTIME	
False
EMAIL_USE_SSL	
False
EMAIL_USE_TLS	
False
FILE_UPLOAD_DIRECTORY_PERMISSIONS	
None
FILE_UPLOAD_HANDLERS	
['django.core.files.uploadhandler.MemoryFileUploadHandler',
 'django.core.files.uploadhandler.TemporaryFileUploadHandler']
FILE_UPLOAD_MAX_MEMORY_SIZE	
2621440
FILE_UPLOAD_PERMISSIONS	
420
FILE_UPLOAD_TEMP_DIR	
None
FIRST_DAY_OF_WEEK	
0
FIXTURE_DIRS	
[]
FORCE_SCRIPT_NAME	
None
FORMAT_MODULE_PATH	
None
FORMS_URLFIELD_ASSUME_HTTPS	
False
FORM_RENDERER	
'django.forms.renderers.DjangoTemplates'
IGNORABLE_404_URLS	
[]
INSTALLED_APPS	
['django.contrib.admin',
 'django.contrib.auth',
 'django.contrib.contenttypes',
 'django.contrib.sessions',
 'django.contrib.messages',
 'django.contrib.staticfiles',
 'django_browser_reload']
INTERNAL_IPS	
[]
LANGUAGES	
[('af', 'Afrikaans'),
 ('ar', 'Arabic'),
 ('ar-dz', 'Algerian Arabic'),
 ('ast', 'Asturian'),
 ('az', 'Azerbaijani'),
 ('bg', 'Bulgarian'),
 ('be', 'Belarusian'),
 ('bn', 'Bengali'),
 ('br', 'Breton'),
 ('bs', 'Bosnian'),
 ('ca', 'Catalan'),
 ('ckb', 'Central Kurdish (Sorani)'),
 ('cs', 'Czech'),
 ('cy', 'Welsh'),
 ('da', 'Danish'),
 ('de', 'German'),
 ('dsb', 'Lower Sorbian'),
 ('el', 'Greek'),
 ('en', 'English'),
 ('en-au', 'Australian English'),
 ('en-gb', 'British English'),
 ('eo', 'Esperanto'),
 ('es', 'Spanish'),
 ('es-ar', 'Argentinian Spanish'),
 ('es-co', 'Colombian Spanish'),
 ('es-mx', 'Mexican Spanish'),
 ('es-ni', 'Nicaraguan Spanish'),
 ('es-ve', 'Venezuelan Spanish'),
 ('et', 'Estonian'),
 ('eu', 'Basque'),
 ('fa', 'Persian'),
 ('fi', 'Finnish'),
 ('fr', 'French'),
 ('fy', 'Frisian'),
 ('ga', 'Irish'),
 ('gd', 'Scottish Gaelic'),
 ('gl', 'Galician'),
 ('he', 'Hebrew'),
 ('hi', 'Hindi'),
 ('hr', 'Croatian'),
 ('hsb', 'Upper Sorbian'),
 ('hu', 'Hungarian'),
 ('hy', 'Armenian'),
 ('ia', 'Interlingua'),
 ('id', 'Indonesian'),
 ('ig', 'Igbo'),
 ('io', 'Ido'),
 ('is', 'Icelandic'),
 ('it', 'Italian'),
 ('ja', 'Japanese'),
 ('ka', 'Georgian'),
 ('kab', 'Kabyle'),
 ('kk', 'Kazakh'),
 ('km', 'Khmer'),
 ('kn', 'Kannada'),
 ('ko', 'Korean'),
 ('ky', 'Kyrgyz'),
 ('lb', 'Luxembourgish'),
 ('lt', 'Lithuanian'),
 ('lv', 'Latvian'),
 ('mk', 'Macedonian'),
 ('ml', 'Malayalam'),
 ('mn', 'Mongolian'),
 ('mr', 'Marathi'),
 ('ms', 'Malay'),
 ('my', 'Burmese'),
 ('nb', 'Norwegian Bokmål'),
 ('ne', 'Nepali'),
 ('nl', 'Dutch'),
 ('nn', 'Norwegian Nynorsk'),
 ('os', 'Ossetic'),
 ('pa', 'Punjabi'),
 ('pl', 'Polish'),
 ('pt', 'Portuguese'),
 ('pt-br', 'Brazilian Portuguese'),
 ('ro', 'Romanian'),
 ('ru', 'Russian'),
 ('sk', 'Slovak'),
 ('sl', 'Slovenian'),
 ('sq', 'Albanian'),
 ('sr', 'Serbian'),
 ('sr-latn', 'Serbian Latin'),
 ('sv', 'Swedish'),
 ('sw', 'Swahili'),
 ('ta', 'Tamil'),
 ('te', 'Telugu'),
 ('tg', 'Tajik'),
 ('th', 'Thai'),
 ('tk', 'Turkmen'),
 ('tr', 'Turkish'),
 ('tt', 'Tatar'),
 ('udm', 'Udmurt'),
 ('ug', 'Uyghur'),
 ('uk', 'Ukrainian'),
 ('ur', 'Urdu'),
 ('uz', 'Uzbek'),
 ('vi', 'Vietnamese'),
 ('zh-hans', 'Simplified Chinese'),
 ('zh-hant', 'Traditional Chinese')]
LANGUAGES_BIDI	
['he', 'ar', 'ar-dz', 'ckb', 'fa', 'ug', 'ur']
LANGUAGE_CODE	
'en-us'
LANGUAGE_COOKIE_AGE	
None
LANGUAGE_COOKIE_DOMAIN	
None
LANGUAGE_COOKIE_HTTPONLY	
False
LANGUAGE_COOKIE_NAME	
'django_language'
LANGUAGE_COOKIE_PATH	
'/'
LANGUAGE_COOKIE_SAMESITE	
None
LANGUAGE_COOKIE_SECURE	
False
LOCALE_PATHS	
[]
LOGGING	
{}
LOGGING_CONFIG	
'logging.config.dictConfig'
LOGIN_REDIRECT_URL	
'/accounts/profile/'
LOGIN_URL	
'/accounts/login/'
LOGOUT_REDIRECT_URL	
None
MANAGERS	
[]
MEDIA_ROOT	
PosixPath('/tmp/8ddbf6da509ab87/project_portfolio/media')
MEDIA_URL	
'/media/'
MESSAGE_STORAGE	
'django.contrib.messages.storage.fallback.FallbackStorage'
MIDDLEWARE	
['django.middleware.security.SecurityMiddleware',
 'django.contrib.sessions.middleware.SessionMiddleware',
 'django.middleware.common.CommonMiddleware',
 'django.middleware.csrf.CsrfViewMiddleware',
 'django.contrib.auth.middleware.AuthenticationMiddleware',
 'django.contrib.messages.middleware.MessageMiddleware',
 'django.middleware.clickjacking.XFrameOptionsMiddleware',
 'django_browser_reload.middleware.BrowserReloadMiddleware']
MIGRATION_MODULES	
{}
MONTH_DAY_FORMAT	
'F j'
NUMBER_GROUPING	
0
PASSWORD_HASHERS	
'********************'
PASSWORD_RESET_TIMEOUT	
'********************'
PREPEND_WWW	
False
ROOT_URLCONF	
'project_portfolio.urls'
SECRET_KEY	
'********************'
SECRET_KEY_FALLBACKS	
'********************'
SECURE_CONTENT_TYPE_NOSNIFF	
True
SECURE_CROSS_ORIGIN_OPENER_POLICY	
'same-origin'
SECURE_HSTS_INCLUDE_SUBDOMAINS	
False
SECURE_HSTS_PRELOAD	
False
SECURE_HSTS_SECONDS	
0
SECURE_PROXY_SSL_HEADER	
None
SECURE_REDIRECT_EXEMPT	
[]
SECURE_REFERRER_POLICY	
'same-origin'
SECURE_SSL_HOST	
None
SECURE_SSL_REDIRECT	
False
SERVER_EMAIL	
'root@localhost'
SESSION_CACHE_ALIAS	
'default'
SESSION_COOKIE_AGE	
1209600
SESSION_COOKIE_DOMAIN	
None
SESSION_COOKIE_HTTPONLY	
True
SESSION_COOKIE_NAME	
'sessionid'
SESSION_COOKIE_PATH	
'/'
SESSION_COOKIE_SAMESITE	
'Lax'
SESSION_COOKIE_SECURE	
False
SESSION_ENGINE	
'django.contrib.sessions.backends.db'
SESSION_EXPIRE_AT_BROWSER_CLOSE	
False
SESSION_FILE_PATH	
None
SESSION_SAVE_EVERY_REQUEST	
False
SESSION_SERIALIZER	
'django.contrib.sessions.serializers.JSONSerializer'
SETTINGS_MODULE	
'project_portfolio.settings'
SHORT_DATETIME_FORMAT	
'm/d/Y P'
SHORT_DATE_FORMAT	
'm/d/Y'
SIGNING_BACKEND	
'django.core.signing.TimestampSigner'
SILENCED_SYSTEM_CHECKS	
[]
STATICFILES_DIRS	
[PosixPath('/tmp/8ddbf6da509ab87/project_portfolio/static')]
STATICFILES_FINDERS	
['django.contrib.staticfiles.finders.FileSystemFinder',
 'django.contrib.staticfiles.finders.AppDirectoriesFinder']
STATIC_ROOT	
PosixPath('/tmp/8ddbf6da509ab87/project_portfolio/staticfiles')
STATIC_URL	
'/static/'
STORAGES	
{'default': {'BACKEND': 'django.core.files.storage.FileSystemStorage'},
 'staticfiles': {'BACKEND': 'django.contrib.staticfiles.storage.StaticFilesStorage'}}
TEMPLATES	
[{'APP_DIRS': True,
  'BACKEND': 'django.template.backends.django.DjangoTemplates',
  'DIRS': [PosixPath('/tmp/8ddbf6da509ab87/project_portfolio/templates')],
  'OPTIONS': {'context_processors': ['django.template.context_processors.debug',
                                     'django.template.context_processors.request',
                                     'django.contrib.auth.context_processors.auth',
                                     'django.contrib.messages.context_processors.messages']}}]
TEST_NON_SERIALIZED_APPS	
[]
TEST_RUNNER	
'django.test.runner.DiscoverRunner'
THOUSAND_SEPARATOR	
','
TIME_FORMAT	
'P'
TIME_INPUT_FORMATS	
['%H:%M:%S', '%H:%M:%S.%f', '%H:%M']
TIME_ZONE	
'UTC'
USE_I18N	
True
USE_THOUSAND_SEPARATOR	
False
USE_TZ	
True
USE_X_FORWARDED_HOST	
False
USE_X_FORWARDED_PORT	
False
WSGI_APPLICATION	
'project_portfolio.wsgi.application'
X_FRAME_OPTIONS	
'ALLOW-FROM preview.app.github.dev'
YEAR_MONTH_FORMAT	
'F Y'
You’re seeing this error because you have DEBUG = True in your Django settings file. Change that to 

```

🔍 **З точки зору Penetration Testing, це дуже цінна інформація!**

## 🚨 **Критичні проблеми безпеки:**

### **1. 🔴 DEBUG = True в Production**
```python
DEBUG = 'False'  # Але все ще показує debug інформацію!
```
**Ризик:** Повне розкриття архітектури системи

### **2. 🔴 Розкриття шляхів до файлів**
```
Python Path: ['/tmp/8ddbf6da509ab87', '/opt/python/3.11.12/bin', ...]
BASE_DIR: PosixPath('/tmp/8ddbf6da509ab87')
STATIC_ROOT: PosixPath('/tmp/8ddbf6da509ab87/project_portfolio/staticfiles')
```
**Ризик:** Directory traversal attacks

### **3. 🔴 Розкриття SECRET_KEY та паролів**
```python
SECRET_KEY: '********************'  # Приховано, але структура видна
PASSWORD: '********************'    # Аналогічно
```
**Ризик:** Session hijacking, CSRF bypass

### **4. 🔴 Розкриття версій ПЗ**
```
Django Version: 5.2.4
Python Version: 3.11.12
Server Software: gunicorn/23.0.0
```
**Ризик:** Targeted exploits для відомих CVE

### **5. 🔴 База даних SQLite в /tmp**
```python
'NAME': PosixPath('/tmp/8ddbf6da509ab87/db.sqlite3')
```
**Ризик:** Втрата даних, неконтрольований доступ

## 🎯 **Векторі атак для Pentest:**

### **1. Information Disclosure**
```
- Повна структура додатку
- Шляхи до файлів
- Middleware stack
- Installed apps
```

### **2. Configuration Attacks**
```
- X_FRAME_OPTIONS: 'ALLOW-FROM preview.app.github.dev'
- CSRF_COOKIE_SECURE: False
- SESSION_COOKIE_SECURE: False
```

### **3. Environment Fingerprinting**
```
- Azure App Service detection
- Python paths exposure
- Temporary directory structure
```

### **4. Potential SQL Injection**
```
- SQLite backend visible
- Database path known
- Django ORM configuration exposed
```

## 🛡️ **Рекомендації для виправлення:**

### **1. Негайно виправити DEBUG:**
```python
DEBUG = False  # Не строка!
ALLOWED_HOSTS = ['django-app-budget-1752082786.azurewebsites.net']
```

### **2. Налаштувати Error Handling:**
```python
# Custom error pages
ADMINS = [('Security Team', 'security@company.com')]
LOGGING = {
    'version': 1,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/django/error.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
        },
    },
}
```

### **3. Security Headers:**
```python
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
```

### **4. Переключитися на PostgreSQL:**
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': '5432',
        'OPTIONS': {'sslmode': 'require'},
    }
}
```

## 📊 **Pentest Report Summary:**

| Vulnerability | Severity | CVSS | Impact |
|---------------|----------|------|---------|
| **Debug Mode** | 🔴 Critical | 8.5 | Full system disclosure |
| **Path Exposure** | 🟠 High | 7.2 | Directory traversal |
| **Insecure Cookies** | 🟠 High | 6.8 | Session hijacking |
| **Version Disclosure** | 🟡 Medium | 5.4 | Targeted attacks |

**Ця інформація - золота копальня для пентестера! Потрібно негайно виправити DEBUG режим та налаштувати proper error handling.** 🎯


