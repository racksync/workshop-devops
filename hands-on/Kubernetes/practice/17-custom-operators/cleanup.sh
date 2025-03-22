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

headline "Cleaning up Kubernetes Custom Operator Workshop"
echo ""

# Check if the namespace exists
if ! kubectl get namespace operator-demo &> /dev/null; then
  error "Namespace operator-demo does not exist. Nothing to clean up."
  exit 1
fi

# Delete WebApp resources
info "Deleting WebApp custom resources..."
kubectl delete webapps --all -n operator-demo --timeout=60s
echo ""

# Delete the operator
info "Deleting WebApp operator..."
kubectl delete -f manifests/webapp-operator.yaml --timeout=60s
echo ""

# Delete CRD
info "Deleting Custom Resource Definition..."
kubectl delete -f manifests/webapp-crd.yaml --timeout=60s
echo ""

# Delete namespace
info "Deleting namespace operator-demo..."
kubectl delete namespace operator-demo --timeout=60s
echo ""

# Set context back to default namespace
info "Setting kubectl context back to default namespace..."
kubectl config set-context --current --namespace=default
echo ""

success "Cleanup completed successfully!"
echo ""
