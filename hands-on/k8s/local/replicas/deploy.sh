#!/bin/bash

# Script for installing Kubernetes resources for NGINX Replicas Demo

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

print_status "Starting NGINX Replicas Demo installation on Kubernetes..."

# 1. Create Namespace
print_status "1. Creating Namespace 'replica-demo'..."
kubectl create namespace replica-demo
check_error "Cannot create Namespace"
kubectl config set-context --current --namespace=replica-demo
check_error "Cannot set current namespace"
print_success "Namespace created and set successfully"

# 2. Create ConfigMap for custom HTML content
print_status "2. Creating ConfigMap with custom index.html..."
kubectl apply -f nginx-configmap.yaml
check_error "Cannot create ConfigMap"
print_success "ConfigMap created successfully"

# 3. Create Deployment
print_status "3. Creating NGINX Deployment with 3 replicas..."
kubectl apply -f nginx-deployment.yaml
check_error "Cannot create Deployment"
print_success "Deployment created successfully"

# Wait for Deployment to be ready
print_status "   Waiting for Deployment to be ready..."
kubectl wait --for=condition=Available deployment/nginx-deployment --timeout=60s
check_error "Deployment is not ready within the specified timeout"

# 4. Create Service
print_status "4. Creating Service for NGINX..."
kubectl apply -f nginx-service.yaml
check_error "Cannot create Service"
print_success "Service created successfully"

# Wait for Service to be ready
print_status "   Waiting for Service to be ready..."
kubectl get service nginx-service
check_error "Cannot check Service status"

# 5. Create Ingress
print_status "5. Creating Ingress for NGINX..."
kubectl apply -f nginx-ingress.yaml
check_error "Cannot create Ingress"
print_success "Ingress created successfully"

# Verify Ingress Controller is running
print_status "   Verifying Ingress Controller..."
if ! kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx 2>/dev/null | grep -q Running; then
  print_status "   Note: Ingress Controller not found in namespace 'ingress-nginx'. Make sure you have installed an Ingress Controller in your cluster."
  print_status "   For Minikube: 'minikube addons enable ingress'"
  print_status "   For other clusters, follow installation instructions for NGINX Ingress Controller"
fi

# Display Ingress information
print_status "   Ingress information:"
kubectl get ingress nginx-ingress
check_error "Cannot display Ingress information"

# 6. Display Pods Information
print_status "6. Checking Replica Pods status:"
kubectl get pods -o wide
check_error "Cannot display Pods information"

# Additional verification steps
print_status "7. Verifying connectivity:"
print_status "   Checking if DNS resolution is working..."
if ! host nginx.k8s.local &>/dev/null; then
  print_status "   Warning: 'nginx.k8s.local' cannot be resolved. Make sure it's added to your /etc/hosts file"
  print_status "   You can add it with: echo '127.0.0.1 nginx.k8s.local' | sudo tee -a /etc/hosts"
fi

print_success "NGINX Replicas Demo installation completed successfully"

# Display testing instructions
echo ""
print_status "Testing:"
echo "1. Add the following line to your hosts file:"
echo "   127.0.0.1 nginx.k8s.local"
echo ""
echo "2. Test accessing NGINX via the Ingress:"
echo "   http://nginx.k8s.local"
echo ""
echo "3. Test auto-healing by deleting one pod:"
echo "   kubectl delete pod <pod-name>"
echo "   kubectl get pods (to see auto-healing in action)"
echo ""
echo "4. Try scaling the deployment:"
echo "   kubectl scale deployment nginx-deployment --replicas=5"
echo ""
echo "5. To remove all resources, use the command:"
echo "   kubectl delete namespace replica-demo"
echo "   or run the cleanup.sh script"
echo ""
