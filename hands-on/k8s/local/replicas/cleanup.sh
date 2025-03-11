#!/bin/bash

# Script for removing Kubernetes resources of NGINX Replicas Demo

# Define color variables
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

print_status "Removing all resources of NGINX Replicas Demo..."

# Check if namespace exists
if kubectl get namespace replica-demo &> /dev/null; then
  # Remove all resources by deleting the namespace
  print_status "Deleting Namespace 'replica-demo' and all resources within it..."
  kubectl delete namespace replica-demo
  
  # Wait for namespace to be fully deleted
  print_status "Waiting for namespace to be completely removed..."
  while kubectl get namespace replica-demo &> /dev/null; do
    echo -n "."
    sleep 1
  done
  echo ""
  
  print_success "All resources have been removed successfully"
else
  print_status "Namespace 'replica-demo' not found, it may have been already deleted"
fi

# Reset default namespace if needed
print_status "Resetting to default namespace..."
kubectl config set-context --current --namespace=default

print_success "Cleanup completed"
