# Docker Hub CI/CD Workshop

This repository demonstrates how to set up CI/CD pipelines to automatically build and push Docker images to Docker Hub using different CI/CD platforms.

## Project Structure

- `app/app.py`: A simple Python Flask application that serves a single page
- `requirements.txt`: Python dependencies
- `Dockerfile`: Instructions to build the Docker image
- `.github/workflows/docker-build-push.yml`: GitHub Actions workflow
- `.gitlab-ci.yml`: GitLab CI configuration
- `bitbucket-pipelines.yml`: Bitbucket Pipelines configuration

## Local Development

### Prerequisites
- Docker installed on your machine
- Python 3.9 or higher (for local development without Docker)

### Running locally with Python

```bash
pip install -r requirements.txt
python app/app.py
```

Then visit `http://localhost:5000` in your browser.

### Running locally with Docker

```bash
docker build -t docker-hub-workshop .
docker run -p 5000:5000 docker-hub-workshop
```

Then visit `http://localhost:5000` in your browser.

## CI/CD Pipeline Setup

### Required Secrets

For all CI/CD platforms, you'll need to set up the following secrets:

- `DOCKER_HUB_USERNAME`: Your Docker Hub username
- `DOCKER_HUB_PASSWORD` or `DOCKER_HUB_ACCESS_TOKEN`: Your Docker Hub password or access token

### GitHub Actions

The pipeline in `.github/workflows/docker-build-push.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

### GitLab CI

The pipeline in `.gitlab-ci.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

### Bitbucket Pipelines

The pipeline in `bitbucket-pipelines.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

## Security Best Practices

- Always use access tokens instead of passwords for Docker Hub authentication
- Regularly rotate your access tokens
- Use specific image tags instead of `latest` in production environments
- Consider implementing vulnerability scanning in your CI/CD pipeline

## License

MIT
