# DevOps Workshop: Modern PHP Application with CI/CD

![RACKSYNC CO., LTD.](https://github.com/racksync/devops-workshop/raw/main/assets/racksync-logo.png)

## Overview

This workshop by RACKSYNC CO., LTD. provides a practical hands-on experience with DevOps practices using a modern PHP application. Participants will learn how to containerize a PHP application and implement continuous integration and deployment (CI/CD) pipelines across multiple platforms.

## Application Features

- Modern responsive design using Bootstrap 5
- Multi-page application with component-based architecture
- Simple routing system
- Clean code organization
- Cross-platform CI/CD implementation (GitHub Actions, GitLab CI, and Bitbucket Pipelines)

## Prerequisites

- Docker and Docker Compose
- Git
- Basic understanding of PHP
- Account on at least one of: GitHub, GitLab, or Bitbucket
- A CI/CD runner/agent (self-hosted or cloud-based)

## Quick Start Guide

### 1. Clone the Repository

```bash
git clone https://github.com/racksync/devops-workshop.git
cd devops-workshop/hands-on/php
```

### 2. Build and Run Locally

```bash
docker build -t php-app:local .
docker run -d -p 8080:80 --name php-local php-app:local
```

Visit http://localhost:8080 in your browser to see the application running.

## Project Structure

```
/hands-on/php/
├── src/                        # Application source code
│   ├── assets/                 # Static assets
│   │   ├── css/                # CSS files
│   │   └── js/                 # JavaScript files
│   ├── includes/               # Reusable PHP components
│   │   ├── header.php          # Page header with navigation
│   │   └── footer.php          # Page footer
│   ├── pages/                  # Page-specific content
│   │   ├── home.php            # Homepage content
│   │   ├── about.php           # About page content
│   │   └── services.php        # Services page content
│   ├── index.php               # Main application entry point with routing
│   └── landing.html            # Simple landing page
├── .github/                    # GitHub Actions configuration
│   └── workflows/              
│       ├── main.yml            # Production deployment workflow
│       └── dev.yml             # Development deployment workflow
├── deploy-scripts/             # Deployment scripts for Bitbucket Pipelines
│   ├── deploy-dev.sh           # Script to deploy to dev environment
│   └── deploy-prod.sh          # Script to deploy to production environment
├── .gitlab-ci.yml              # GitLab CI configuration
├── bitbucket-pipelines.yml     # Bitbucket Pipelines configuration
├── Dockerfile                  # Docker configuration
└── README.md                   # This documentation
```

## CI/CD Implementation

This workshop includes CI/CD configurations for three popular platforms. Choose the one that best suits your needs or experiment with all three.

### GitHub Actions

Located in `.github/workflows/`:

- **dev.yml**: Triggered on pushes to the `dev` branch
  - Builds and deploys to development environment (port 8082)
  - Automatic deployment

- **main.yml**: Triggered on pushes to the `main` branch
  - Builds and deploys to production environment (port 8081)
  - Automatic deployment

### GitLab CI

Located in `.gitlab-ci.yml`:

- **Development Pipeline**: Triggered on pushes to the `dev` branch
  - Builds and tests the application
  - Automatic deployment to development environment (port 8082)

- **Production Pipeline**: Triggered on pushes to the `main` branch
  - Builds and tests the application
  - Manual deployment to production environment (port 8081)

### Bitbucket Pipelines

Located in `bitbucket-pipelines.yml`:

- **Development Pipeline**: Triggered on pushes to the `dev` branch
  - Builds and tests the application
  - Deploys to development environment using SSH (port 8082)

- **Production Pipeline**: Triggered on pushes to the `main` branch
  - Builds and tests the application
  - Manual deployment to production environment using SSH (port 8081)
  - Requires approval before deployment

## Workshop Exercises

### Exercise 1: Local Development

1. Clone the repository
2. Build and run the Docker container locally
3. Make changes to the application:
   - Add a new image to the homepage
   - Change text on the about page
   - Add a new service to the services page
4. Test your changes locally

### Exercise 2: GitHub Actions CI/CD

1. Fork the repository to your GitHub account
2. Set up a self-hosted GitHub Actions runner
   ```bash
   # Download runner script (replace with appropriate script for your OS)
   curl -o actions-runner-linux-x64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-linux-x64-2.300.2.tar.gz
   tar xzf ./actions-runner-linux-x64-2.300.2.tar.gz
   
   # Configure runner
   ./config.sh --url https://github.com/[YOUR_USERNAME]/devops-workshop --token [YOUR_TOKEN]
   
   # Install as a service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```
3. Push changes to the `dev` branch and observe the pipeline
4. Merge to `main` when satisfied with your changes

### Exercise 3: GitLab CI/CD

1. Import the project into GitLab
2. Set up a GitLab runner
   ```bash
   # Download and install GitLab Runner
   curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
   sudo apt-get install gitlab-runner
   
   # Register the runner
   sudo gitlab-runner register
   # Enter your GitLab instance URL
   # Enter the registration token
   # Enter a description for the runner
   # Enter tags for the runner (e.g., "docker", "shell")
   # Choose an executor (e.g., "shell")
   
   # Start the runner
   sudo gitlab-runner start
   ```
3. Push changes to the `dev` branch and observe the pipeline
4. Create a merge request to `main` when ready

### Exercise 4: Bitbucket Pipelines CI/CD

1. Import the project into Bitbucket
2. Enable Bitbucket Pipelines for your repository
3. Set up required environment variables:
   - `SSH_USER`: SSH user for deployment
   - `DEV_SERVER`: Hostname/IP of development server
   - `PROD_SERVER`: Hostname/IP of production server
4. Set up SSH keys for deployment
5. Push changes to the `dev` branch and observe the pipeline
6. Create a pull request to `main` when ready

### Exercise 5: Feature Branch Workflow

1. Choose a CI/CD platform from the above options
2. Create a new feature branch from `dev`
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/new-feature
   ```
3. Implement a new feature (e.g., contact page, gallery, etc.)
4. Test locally using Docker
5. Push your branch and create a pull/merge request to `dev`
6. Observe CI/CD pipeline testing your changes
7. After approval and merge to `dev`, verify deployment to development environment
8. Create a pull/merge request from `dev` to `main` for production deployment

## Best Practices

- **Version Control**:
  - Use feature branches for development
  - Write meaningful commit messages
  - Review code before merging

- **Docker**:
  - Keep images small and efficient
  - Use specific version tags for base images
  - Implement multi-stage builds for complex applications

- **CI/CD**:
  - Test before pushing
  - Implement proper testing in pipelines
  - Use separate environments for development and production
  - Implement deployment approval for production

## Troubleshooting

### Common Issues

- **Docker Permission Issues**
  ```bash
  # Add your user to the docker group
  sudo usermod -aG docker $USER
  newgrp docker
  ```

- **Port Conflicts**
  ```bash
  # Check if ports are already in use
  sudo lsof -i :8080
  sudo lsof -i :8081
  sudo lsof -i :8082
  
  # Change port mapping if needed
  docker run -p 8090:80 --name php-local php-app:local
  ```

- **CI/CD Runner Connection Issues**
  - Verify network connectivity between runners and repositories
  - Check runner logs for detailed error messages
  - Ensure proper permissions for deployment

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Bitbucket Pipelines Documentation](https://support.atlassian.com/bitbucket-cloud/docs/bitbucket-pipelines-configuration-reference/)
- [PHP Best Practices](https://phptherightway.com/)

## About RACKSYNC

RACKSYNC CO., LTD. is a leading provider of DevOps solutions and training in Thailand. We specialize in helping organizations implement modern infrastructure practices to improve their development workflows and operational efficiency.

For more information, visit our [GitHub repository](https://github.com/racksync/devops-workshop) or contact our team for personalized training and consultation.

## License

This workshop material is provided by RACKSYNC CO., LTD. and is licensed under the MIT License.
