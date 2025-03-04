FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Add an environment variable to ensure Django can find settings
ENV PYTHONPATH=/app
ENV DJANGO_SETTINGS_MODULE=django_project.settings

# Remove problematic collectstatic command until project structure is fixed
# RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "django_project.wsgi:application"]
