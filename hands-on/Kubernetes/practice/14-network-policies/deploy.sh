#!/bin/bash

# Define color functions
function print_headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function print_info() {
  echo -e "\033[0;34m$1\033[0m"
}

function print_success() {
  echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
  echo -e "\033[0;31m$1\033[0m"
}

# Introduction
print_headline "Network Policies Workshop - Deployment Script"
print_info "This script will set up the Network Policies demonstration environment."
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
  print_error "kubectl command not found. Please install kubectl first."
  exit 1
fi

# Create namespace
print_info "Creating namespace 'netpol-demo'"
kubectl create namespace netpol-demo
if [ $? -eq 0 ]; then
  print_success "Namespace created successfully"
else
  print_error "Failed to create namespace"
  exit 1
fi
echo ""

# Switch context to the new namespace
print_info "Switching context to namespace 'netpol-demo'"
kubectl config set-context --current --namespace=netpol-demo
echo ""

# Deploy application components
print_info "Deploying application components (frontend, backend, database, monitoring)"
kubectl apply -f app-deployment.yaml
if [ $? -eq 0 ]; then
  print_success "Applications deployed successfully"
else
  print_error "Failed to deploy applications"
  exit 1
fi
echo ""

# Deploy services
print_info "Deploying services"
kubectl apply -f app-services.yaml
if [ $? -eq 0 ]; then
  print_success "Services deployed successfully"
else
  print_error "Failed to deploy services"
  exit 1
fi
echo ""

# Deploy test pod
print_info "Deploying test pod for connectivity tests"
kubectl apply -f test-pod.yaml
if [ $? -eq 0 ]; then
  print_success "Test pod deployed successfully"
else
  print_error "Failed to deploy test pod"
  exit 1
fi
echo ""

# Wait for pods to be ready
print_info "Waiting for all pods to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod --all --timeout=120s
echo ""

# Information about hostname
print_headline "Hostname Configuration"
print_info "The application is configured with hostname: demo.k8s.local"
print_info "To access it locally, add the following line to your /etc/hosts file:"
print_info "127.0.0.1 demo.k8s.local"
echo ""

# Deploy network policies
print_headline "Applying Network Policies"

print_info "1. Applying default deny policy"
kubectl apply -f default-deny.yaml
echo ""

print_info "2. Allowing frontend ingress access"
kubectl apply -f frontend-policy.yaml
echo ""

print_info "3. Allowing frontend to backend communication"
kubectl apply -f frontend-to-backend.yaml
echo ""

print_info "4. Allowing backend to database communication"
kubectl apply -f backend-to-database.yaml
echo ""

print_info "5. Setting up monitoring access"
kubectl apply -f monitoring-policy.yaml
echo ""

print_info "6. Allowing DNS access for all pods"
kubectl apply -f allow-dns.yaml
echo ""

# Summary
print_headline "Deployment Complete!"
print_info "The Network Policies workshop environment has been set up successfully."
print_info "Use 'test.sh' to test the network connectivity between pods."
print_info "Use 'cleanup.sh' to remove all resources when finished."
echo ""

# Display deployed resources
print_info "Deployed pods:"
kubectl get pods
echo ""

print_info "Deployed services:"
kubectl get svc
echo ""

print_info "Applied network policies:"
kubectl get networkpolicies
echo ""
