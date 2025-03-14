#!/bin/bash

# Color function definitions
function print_info() { echo -e "\033[0;34m${1}\033[0m"; }
function print_success() { echo -e "\033[0;32m${1}\033[0m"; }
function print_error() { echo -e "\033[0;31m${1}\033[0m"; }
function print_headline() { echo -e "\033[1;33m${1}\033[0m"; }

# Check if doctl is installed
print_headline "Checking doctl installation"
if ! command -v doctl &> /dev/null; then
    print_error "doctl is not installed"
    print_info "Please install doctl first: https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Verify doctl authentication
print_headline "Verifying doctl authentication"
if ! doctl account get &> /dev/null; then
    print_error "doctl is not authenticated"
    print_info "Please run: doctl auth init"
    exit 1
fi

# Check Kubernetes context
print_headline "Verifying Kubernetes connection"
if ! kubectl cluster-info &> /dev/null; then
    print_error "Not connected to a Kubernetes cluster"
    print_info "Please ensure you're connected to your DO Kubernetes cluster"
    print_info "Run: doctl kubernetes cluster kubeconfig save <cluster-name>"
    exit 1
fi

# Create namespace
print_headline "Creating namespace python-demo"
kubectl create namespace python-demo

echo ""

# Build Docker image
print_headline "Building Docker image"
docker build -t python-app:latest .

echo ""

# Deploy application
print_headline "Deploying application"
kubectl apply -f k8s.yaml

echo ""

# Wait for deployment
print_headline "Waiting for deployment to be ready"
kubectl wait --namespace python-demo \
  --for=condition=ready pod \
  --selector=app=python-app \
  --timeout=90s

echo ""

print_success "Deployment completed successfully"
print_info "Access the application at http://k8s.logmatt.com"
