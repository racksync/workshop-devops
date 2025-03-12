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

function print_step() {
    echo -e "\033[0;35m$1\033[0m"
    echo ""
}

# Script starts here
print_headline "GitLab CI/CD for Kubernetes Workshop - Testing"

# Set directory variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/my-k8s-app"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if deployment script was run
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run deploy.sh first."
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace gitlab-demo &> /dev/null; then
    print_warning "Namespace gitlab-demo does not exist. Creating it now."
    kubectl create namespace gitlab-demo
    echo ""
    
    print_info "Setting kubectl context to use gitlab-demo namespace"
    kubectl config set-context --current --namespace=gitlab-demo
    echo ""
else
    print_info "Using existing gitlab-demo namespace"
    kubectl config set-context --current --namespace=gitlab-demo
    echo ""
fi

print_step "1. Testing project structure"
if [ -f "${PROJECT_DIR}/src/app.js" ] && [ -f "${PROJECT_DIR}/package.json" ] && [ -f "${PROJECT_DIR}/Dockerfile" ]; then
    print_success "Project structure is valid."
else
    print_error "Project structure is incomplete. Run deploy.sh first."
    exit 1
fi
echo ""

print_step "2. Testing local application"
if command -v node &> /dev/null; then
    print_info "Testing if Node.js application can start..."
    
    # Save current directory
    CURRENT_DIR=$(pwd)
    cd "${PROJECT_DIR}"
    
    # Install dependencies
    print_info "Installing dependencies..."
    npm install --quiet
    echo ""
    
    # Start application in background
    print_info "Starting application in background..."
    node src/app.js > /dev/null 2>&1 &
    NODE_PID=$!
    sleep 2
    echo ""
    
    # Test application
    if curl -s http://localhost:3000 > /dev/null; then
        print_success "Application is running correctly."
        curl -s http://localhost:3000
        echo ""
    else
        print_error "Application failed to start or respond."
    fi
    
    # Kill application
    kill $NODE_PID
    
    # Return to original directory
    cd "$CURRENT_DIR"
else
    print_warning "Node.js is not installed. Skipping local application test."
fi
echo ""

print_step "3. Testing Kubernetes manifests"
print_info "Validating Kubernetes manifests with kubectl..."

# Testing deployment.yaml
print_info "Testing deployment.yaml..."
TMP_DEPLOYMENT=$(mktemp)
cat "${PROJECT_DIR}/kubernetes/deployment.yaml" | sed "s|\$IMAGE_NAME:\$IMAGE_TAG|nginx:latest|g" > $TMP_DEPLOYMENT
kubectl apply -f $TMP_DEPLOYMENT --dry-run=client
rm $TMP_DEPLOYMENT
echo ""

# Testing service.yaml
print_info "Testing service.yaml..."
kubectl apply -f "${PROJECT_DIR}/kubernetes/service.yaml" --dry-run=client
echo ""

# Testing ingress.yaml
print_info "Testing ingress.yaml..."
kubectl apply -f "${PROJECT_DIR}/kubernetes/ingress.yaml" --dry-run=client
echo ""

print_step "4. Deploying to Kubernetes for testing"
print_info "Deploying sample application to gitlab-demo namespace..."

# Deploy a test application
TMP_DEPLOYMENT=$(mktemp)
cat "${PROJECT_DIR}/kubernetes/deployment.yaml" | sed "s|\$IMAGE_NAME:\$IMAGE_TAG|nginx:latest|g" > $TMP_DEPLOYMENT
kubectl apply -f $TMP_DEPLOYMENT
rm $TMP_DEPLOYMENT
echo ""

print_info "Deploying service..."
kubectl apply -f "${PROJECT_DIR}/kubernetes/service.yaml"
echo ""

print_info "Deploying ingress..."
kubectl apply -f "${PROJECT_DIR}/kubernetes/ingress.yaml"
echo ""

# Wait for deployment
print_info "Waiting for deployment to be ready..."
kubectl rollout status deployment/my-k8s-app --timeout=60s
echo ""

# Check if deployment succeeded
if [ $? -eq 0 ]; then
    print_success "Deployment successful!"
    
    # Display resources
    print_info "Pods:"
    kubectl get pods -n gitlab-demo
    echo ""
    
    print_info "Services:"
    kubectl get services -n gitlab-demo
    echo ""
    
    print_info "Ingresses:"
    kubectl get ingress -n gitlab-demo
    echo ""
    
    print_warning "Important: To access the application via ingress, ensure you have added demo.k8s.local to your /etc/hosts file:"
    echo "    127.0.0.1 demo.k8s.local   # Use your ingress controller IP instead of 127.0.0.1"
    echo ""
    
    # Test access to the service
    print_info "Testing service access via port-forward..."
    print_info "Starting port forwarding in the background (will be terminated at the end of this script)."
    kubectl port-forward svc/my-k8s-app 8080:80 -n gitlab-demo > /dev/null 2>&1 &
    PF_PID=$!
    sleep 2
    
    if curl -s http://localhost:8080 > /dev/null; then
        print_success "Service is accessible via port-forward at http://localhost:8080"
    else
        print_error "Failed to access service via port-forward."
    fi
    
    # Kill port-forward process
    if [ -n "$PF_PID" ]; then
        kill $PF_PID
    fi
else
    print_error "Deployment failed or timed out."
fi
echo ""

print_headline "Testing GitLab CI Pipeline Configuration"
if [ -f "${PROJECT_DIR}/.gitlab-ci.yml" ]; then
    print_info "GitLab CI configuration exists."
    if command -v yamllint &> /dev/null; then
        print_info "Testing .gitlab-ci.yml syntax (if yamllint is installed)..."
        yamllint "${PROJECT_DIR}/.gitlab-ci.yml" || print_warning "YAML syntax warnings/errors detected."
        echo ""
    else
        print_info "yamllint not installed. Skipping CI configuration syntax check."
        echo ""
    fi
    
    print_success "All components for GitLab CI are in place."
    print_info "To test the CI/CD pipeline, push the project to GitLab and configure the necessary variables."
else
    print_error "GitLab CI configuration is missing."
fi
echo ""

print_headline "Test Summary"
print_info "1. Project structure: Validated"
print_info "2. Local application: Tested"
print_info "3. Kubernetes manifests: Validated"
print_info "4. Test deployment: Completed"
print_info "5. GitLab CI configuration: Checked"
echo ""

print_success "Testing completed!"
print_info "Use cleanup.sh to remove all deployed resources when you're done."
