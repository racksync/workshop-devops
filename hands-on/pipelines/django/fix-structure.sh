#!/bin/bash

# Create django_project directory if it doesn't exist
mkdir -p django_project

# If settings.py exists in app/ but not in django_project/, copy it
if [ -f "app/settings.py" ] && [ ! -f "django_project/settings.py" ]; then
  echo "Moving settings.py from app/ to django_project/"
  cp app/settings.py django_project/settings.py
fi

# Ensure django_project has __init__.py to make it a proper Python package
touch django_project/__init__.py

# Check for wsgi.py, create if missing
if [ ! -f "django_project/wsgi.py" ]; then
  echo "Creating wsgi.py"
  cat > django_project/wsgi.py << 'EOF'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_project.settings')
application = get_wsgi_application()
EOF
fi

# Check for urls.py, create if missing
if [ ! -f "django_project/urls.py" ]; then
  echo "Creating urls.py"
  cat > django_project/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('app.urls')),
]
EOF
fi

echo "Project structure fixed!"
