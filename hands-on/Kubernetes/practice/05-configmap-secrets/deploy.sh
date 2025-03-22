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

print_success "====== Deploying ConfigMap and Secret Demo ======"

# Create namespace
print_status "Creating namespace..."
kubectl create namespace config-demo

# Set current context to use this namespace
print_status "Setting namespace context..."
kubectl config set-context --current --namespace=config-demo

# Create ConfigMaps
print_status "Creating ConfigMaps..."
kubectl apply -f simple-configmap.yaml
echo "Creating JSON ConfigMap from file..."
echo '{
  "apiEndpoint": "https://api.example.com",
  "enableFeatureA": true,
  "maxConnections": 100
}' > config.json
kubectl create configmap json-config --from-file=config.json
kubectl apply -f feature-flags.yaml

# Create Secrets
print_status "Creating Secrets..."
kubectl apply -f app-secret.yaml
kubectl create secret generic api-keys \
  --from-literal=api-key=2f5a14d7e9c83b4 \
  --from-literal=api-secret=c87d4pq39fjwlc2890f

# Create test resources
print_status "Creating demo pod..."
kubectl apply -f app-pod.yaml

# Create real-world example
print_status "Creating real-world example..."
kubectl apply -f real-world-example.yaml

# Wait for resources to be ready
print_status "Waiting for resources to be ready..."
sleep 5

# Show created resources
print_success "====== Resources Created ======"
print_status "ConfigMaps:"
kubectl get configmaps
print_status "Secrets:"
kubectl get secrets
print_status "Pods:"
kubectl get pods

print_success "====== ConfigMap and Secret Demo Deployed Successfully ======"
print_status "To view demo output, run:"
echo "kubectl logs config-demo-pod"
print_status "To test ConfigMap updates, run:"
echo "kubectl apply -f update-configmap.yaml"
print_status "To cleanup all resources, run:"
echo "./cleanup.sh"
