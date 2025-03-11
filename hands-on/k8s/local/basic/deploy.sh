#!/bin/bash

# Script for installing Kubernetes resources for NGINX Demo

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

# Function for displaying error messages
print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function for checking errors
check_error() {
  if [ $? -ne 0 ]; then
    print_error "$1"
    exit 1
  fi
}

print_status "Starting NGINX Demo installation on Kubernetes..."

# 1. Create Namespace
print_status "1. Creating Namespace 'basic-demo'..."
kubectl apply -f namespace.yaml
check_error "Cannot create Namespace"
print_success "Namespace created successfully"

# Wait for Namespace to be ready
print_status "   Waiting for Namespace to be ready..."
kubectl get namespace basic-demo -o jsonpath='{.status.phase}' | grep -q Active
check_error "Namespace is not ready"

# 2. Create Pod
print_status "2. Creating NGINX Pod..."
kubectl apply -f nginx-pod.yaml
check_error "Cannot create Pod"
print_success "Pod created successfully"

# Wait for Pod to be ready
print_status "   Waiting for Pod to be ready..."
kubectl wait --for=condition=Ready pod/nginx-pod -n basic-demo --timeout=60s
check_error "Pod is not ready within the specified timeout"

# 3. Create Service
print_status "3. Creating Service for NGINX..."
kubectl apply -f nginx-service.yaml
check_error "Cannot create Service"
print_success "Service created successfully"

# Wait for Service to be ready
print_status "   Waiting for Service to be ready..."
kubectl get service nginx-service -n basic-demo
check_error "Cannot check Service status"

# 4. Create Ingress
print_status "4. Creating Ingress for NGINX..."
kubectl apply -f nginx-ingress.yaml
check_error "Cannot create Ingress"
print_success "Ingress created successfully"

# Display Ingress information
print_status "   Ingress information:"
kubectl get ingress nginx-ingress -n basic-demo
check_error "Cannot display Ingress information"

print_success "NGINX Demo installation completed successfully"

# Display testing instructions
echo ""
print_status "Testing:"
echo "1. Add the following line to your hosts file:"
echo "   127.0.0.1 nginx.k8s.local"
echo ""
echo "2. Test accessing NGINX via port-forward:"
echo "   kubectl port-forward service/nginx-service 8080:80 -n basic-demo"
echo "   Then open your browser to http://localhost:8080"
echo ""
echo "3. If you have an Ingress Controller installed, you can access it at:"
echo "   http://nginx.k8s.local"
echo ""
echo "4. To remove all resources, use the command:"
echo "   kubectl delete namespace basic-demo"
echo ""
