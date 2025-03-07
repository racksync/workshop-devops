FROM python:3.12-slim

ARG BUILD_TAG
ENV BUILD_TAG=${BUILD_TAG}

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Make manage.py executable
RUN chmod +x manage.py

# Add environment variables (these will be overridden by pipeline secrets)
ENV PYTHONPATH=/app
ENV DJANGO_SETTINGS_MODULE=django_project.settings
ENV PYTHONUNBUFFERED=1
# Note: DJANGO_SECRET_KEY should be provided by the CI/CD pipeline
# ENV DJANGO_DEBUG="True" - should also be set in pipeline

EXPOSE 8000

# Display a message if no secret key is provided
CMD if [ -z "$DJANGO_SECRET_KEY" ]; then echo "WARNING: No DJANGO_SECRET_KEY provided. Using a randomly generated key."; fi && \
    gunicorn --bind 0.0.0.0:8000 django_project.wsgi:application
