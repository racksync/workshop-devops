#!/bin/bash

# Functions for colored output
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;36m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

headline "Deploying Kubernetes Custom Operator Workshop"
echo ""

# Create namespace
info "Creating namespace operator-demo..."
kubectl create namespace operator-demo
echo ""

# Set context to the new namespace
info "Setting kubectl context to operator-demo namespace..."
kubectl config set-context --current --namespace=operator-demo
echo ""

# Apply CRD
info "Applying Custom Resource Definition (CRD)..."
kubectl apply -f manifests/webapp-crd.yaml
echo ""

# Wait for CRD to be established
info "Waiting for CRD to be established..."
kubectl wait --for=condition=established --timeout=60s crd/webapps.apps.example.com
echo ""

# Deploy the operator
info "Deploying WebApp operator..."
kubectl apply -f manifests/webapp-operator.yaml
echo ""

# Wait for operator to be ready
info "Waiting for operator to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/webapp-operator
echo ""

# Create sample WebApp resources
info "Creating sample WebApp resources..."
kubectl apply -f manifests/webapp-sample.yaml
echo ""

success "Deployment completed successfully!"
success "You can now interact with your WebApp custom resources."
echo ""
info "To check the status of your WebApps:"
echo "kubectl get webapps"
echo ""
info "To check the deployed resources:"
echo "kubectl get deployments,services,pods"
echo ""
