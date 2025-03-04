# Django Basic Application

This is a simple Django application with Docker configuration for development and deployment.

## Environment Variables

For security, this application uses environment variables for configuration:

- `DJANGO_SECRET_KEY`: A secret key used for cryptographic signing
- `DJANGO_DEBUG`: Set to "True" for development, "False" for production

### Secrets Management

- **Local Development**: For local development, secrets are loaded from a `.env` file.
- **CI/CD Pipeline**: In the CI/CD pipeline, `DJANGO_SECRET_KEY` is provided through the pipeline's secrets management system.

> **Note**: The application will generate a random key if none is provided, but this is only suitable for development as it will invalidate sessions between restarts.

## Running Locally with Virtual Environment

### Prerequisites

- Python 3.12+ installed on your system
- Git

### Setup and Run

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd <repository-directory>/hands-on/django
   ```

2. Create a virtual environment
   ```bash
   # On macOS/Linux
   python -m venv venv
   
   # On Windows
   python -m venv venv
   ```

3. Activate the virtual environment
   ```bash
   # On macOS/Linux
   source venv/bin/activate
   
   # On Windows
   venv\Scripts\activate
   ```

4. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```

5. Run migrations
   ```bash
   python manage.py migrate
   ```

6. Run the development server
   ```bash
   python manage.py runserver
   ```

7. Open your browser and navigate to http://127.0.0.1:8000/

8. To deactivate the virtual environment when finished
   ```bash
   deactivate
   ```

## Running with Docker

1. Copy `.env.example` to `.env` and configure as needed (for local development only)
2. Build the Docker image:
   ```
   docker build -t django-basic .
   ```
3. Run the container:
   ```
   # For local development with .env file
   docker run -p 8000:8000 --env-file .env django-basic
   
   # Alternative: provide secret directly
   docker run -p 8000:8000 -e DJANGO_SECRET_KEY="your-secret-key" -e DJANGO_DEBUG="True" django-basic
   ```

## CI/CD Pipeline Configuration

In the CI/CD pipeline, secrets are injected as environment variables:

1. Add `DJANGO_SECRET_KEY` as a secret in your pipeline platform
2. Configure your deployment job to pass this secret to the container

Example GitHub Actions workflow:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and deploy
        env:
          DJANGO_SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
        run: |
          docker build -t django-basic .
          # Deploy commands here with secret injected
```

## Security Notes

- Never commit secrets to the repository
- Always inject `DJANGO_SECRET_KEY` through environment variables or secrets management
- Turn off debug mode in production by setting `DJANGO_DEBUG=False`
- Review Django security documentation: https://docs.djangoproject.com/en/stable/topics/security/

## GitHub Actions Workflows

The repository includes two workflows:

1. **main.yml**: Runs tests and deploys to production when pushing to main
2. **dev.yml**: Runs tests and deploys to development when pushing to dev
