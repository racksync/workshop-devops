# Django GitHub Actions Workshop

This is a simple Django application demonstrating CI/CD with GitHub Actions.

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

## Docker Deployment

Alternatively, you can use Docker to run the application:

```bash
docker build -t django-app .
docker run -p 8000:8000 django-app
```

## GitHub Actions Workflows

The repository includes two workflows:

1. **main.yml**: Runs tests and deploys to production when pushing to main
2. **dev.yml**: Runs tests and deploys to development when pushing to dev
