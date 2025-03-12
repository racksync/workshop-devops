#!/bin/bash

# Script for removing Kubernetes resources of NGINX Demo

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for displaying status messages
print_status() {
  echo -e "${YELLOW}$1${NC}"
}

# Function for displaying success messages
print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_status "Removing all resources of NGINX Demo..."
echo ""

# Check if namespace exists
if kubectl get namespace basic-demo &> /dev/null; then
  # Remove all resources by deleting the namespace
  print_status "Deleting Namespace 'basic-demo' and all resources within it..."
  echo ""
  kubectl delete namespace basic-demo
  echo ""
  print_success "All resources have been removed successfully"
else
  print_status "Namespace 'basic-demo' not found, it may have been already deleted"
fi

print_status "Cleanup completed"
