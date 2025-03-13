#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for displaying status messages
print_status() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

# Function for displaying success messages
print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function for displaying error messages
print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_success "====== Cleaning up ConfigMap and Secret Demo ======"

# Check if namespace exists
if kubectl get namespace config-demo > /dev/null 2>&1; then
    # Delete all resources created for the demo
    print_status "Deleting all resources in config-demo namespace..."
    
    # Delete test pod
    print_status "Deleting test pod..."
    kubectl delete -f app-pod.yaml --ignore-not-found=true
    
    # Delete real-world examples
    print_status "Deleting real-world example resources..."
    kubectl delete -f real-world-example.yaml --ignore-not-found=true
    
    # Delete ConfigMaps
    print_status "Deleting ConfigMaps..."
    kubectl delete -f simple-configmap.yaml --ignore-not-found=true
    kubectl delete -f update-configmap.yaml --ignore-not-found=true
    kubectl delete -f feature-flags.yaml --ignore-not-found=true
    kubectl delete configmap json-config --ignore-not-found=true
    
    # Delete Secrets
    print_status "Deleting Secrets..."
    kubectl delete -f app-secret.yaml --ignore-not-found=true
    kubectl delete secret api-keys --ignore-not-found=true
    
    # Delete generated config file
    print_status "Deleting generated config file..."
    rm -f config.json

    # Check if any resources are still present
    print_status "Checking for any remaining resources..."
    kubectl get all
    
    # Delete namespace
    print_status "Deleting namespace..."
    kubectl delete namespace config-demo
    
    # Reset context to default namespace
    print_status "Resetting namespace context..."
    kubectl config set-context --current --namespace=default
    
    print_success "====== Cleanup Completed ======"
else
    print_status "Namespace config-demo does not exist. Nothing to clean up."
fi
