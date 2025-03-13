#!/bin/bash

# Function definitions for colored output
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
    echo ""
}

function print_info() {
    echo -e "\033[0;34m$1\033[0m"
    echo ""
}

function print_success() {
    echo -e "\033[0;32m$1\033[0m"
    echo ""
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
    echo ""
}

function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
    echo ""
}

# Script starts here
print_headline "GitLab CI/CD for Kubernetes Workshop - Deployment"

# Set directory variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBERNETES_DIR="${SCRIPT_DIR}/kubernetes"
PROJECT_DIR="${SCRIPT_DIR}/my-k8s-app"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

print_info "Creating namespace gitlab-demo"
kubectl apply -f "${KUBERNETES_DIR}/namespace.yaml"
echo ""

print_info "Setting kubectl context to use gitlab-demo namespace"
kubectl config set-context --current --namespace=gitlab-demo
echo ""

# Create project structure if it doesn't exist
print_info "Setting up project directory structure"

mkdir -p "${PROJECT_DIR}"
mkdir -p "${PROJECT_DIR}/kubernetes"
mkdir -p "${PROJECT_DIR}/src"
mkdir -p "${PROJECT_DIR}/.gitlab/agents/my-agent"
echo ""

# Create sample application files
print_info "Creating sample Node.js application"

cat > "${PROJECT_DIR}/src/app.js" << 'EOL'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from GitLab CI/CD Workshop!');
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
EOL

cat > "${PROJECT_DIR}/package.json" << 'EOL'
{
  "name": "my-k8s-app",
  "version": "1.0.0",
  "description": "Sample app for GitLab CI/CD workshop",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "test": "echo \"Tests passed\" && exit 0",
    "build": "echo \"Build completed\" && exit 0"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOL

cat > "${PROJECT_DIR}/Dockerfile" << 'EOL'
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src/ ./src/

EXPOSE 3000
CMD ["npm", "start"]
EOL
echo ""

# Copy Kubernetes manifests to project directory
print_info "Copying Kubernetes manifests to project directory"
cp "${KUBERNETES_DIR}"/* "${PROJECT_DIR}/kubernetes/"
echo ""

# Create .gitlab-ci.yml file
print_info "Creating .gitlab-ci.yml file"
cat > "${PROJECT_DIR}/.gitlab-ci.yml" << 'EOL'
stages:
  - build
  - test
  - deploy

variables:
  IMAGE_NAME: \$CI_REGISTRY_IMAGE/\$CI_COMMIT_REF_SLUG
  IMAGE_TAG: \$CI_COMMIT_SHA

build:
  stage: build
  image: node:16-alpine
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  image: node:16-alpine
  script:
    - npm ci
    - npm test

build-docker:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  script:
    - docker login -u \$CI_REGISTRY_USER -p \$CI_REGISTRY_PASSWORD \$CI_REGISTRY
    - docker build -t \$IMAGE_NAME:\$IMAGE_TAG .
    - docker push \$IMAGE_NAME:\$IMAGE_TAG
  rules:
    - if: \$CI_COMMIT_BRANCH == "main"

deploy-dev:
  stage: deploy
  image:
    name: bitnami/kubectl:latest
    entrypoint: ['']
  script:
    - echo "Deploying to development environment"
    - sed -i "s|image:.*|image: \$IMAGE_NAME:\$IMAGE_TAG|" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/service.yaml
    - kubectl apply -f kubernetes/ingress.yaml # Apply ingress as well
    - kubectl rollout status deployment/my-k8s-app -n gitlab-demo
  environment:
    name: development
  variables:
    KUBECONFIG: \$KUBE_CONFIG_DEV
  rules:
    - if: \$CI_COMMIT_BRANCH == "develop"

deploy-prod:
  stage: deploy
  image:
    name: bitnami/kubectl:latest
    entrypoint: ['']
  script:
    - echo "Deploying to production environment"
    - sed -i "s|image:.*|image: \$IMAGE_NAME:\$IMAGE_TAG|" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/service.yaml
    - kubectl apply -f kubernetes/ingress.yaml # Apply ingress as well
    - kubectl rollout status deployment/my-k8s-app -n gitlab-demo
  environment:
    name: production
  variables:
    KUBECONFIG: \$KUBE_CONFIG_PROD
  rules:
    - if: \$CI_COMMIT_BRANCH == "main"
  when: manual
EOL
echo ""

# Create GitLab Agent config
print_info "Creating GitLab Kubernetes Agent configuration"
cat > "${PROJECT_DIR}/.gitlab/agents/my-agent/config.yaml" << 'EOL'
ci_access:
  projects:
    - id: path/to/your/project
EOL
echo ""

# Apply kustomization.yaml
print_info "Applying kustomization.yaml"
kubectl apply -k "${KUBERNETES_DIR}"
echo ""

print_success "Project setup complete! The structure has been created in: ${PROJECT_DIR}"
print_info "All Kubernetes manifests are placed in the kubernetes/ directory"
print_info "A sample application is set up in the src/ directory"

print_warning "Important: If you want to use the demo.k8s.local hostname, add it to your /etc/hosts file:"
echo "    127.0.0.1 demo.k8s.local"
echo ""

print_info "Next steps:"
echo "1. Push this project to your GitLab repository"
echo "2. Configure GitLab CI/CD variables (KUBE_CONFIG_DEV and KUBE_CONFIG_PROD)"
echo "3. Set up GitLab Kubernetes Agent if needed (see setup-agent.sh)"
echo ""

print_success "You can now run './test.sh' to test your deployment"
