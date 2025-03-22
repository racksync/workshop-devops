#!/bin/bash

# Color functions
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

function warning() {
  echo -e "\033[0;33m$1\033[0m"
}

headline "Cleaning up Kubernetes Dashboard resources"
echo ""

# Delete any port-forward process that might be running
info "Stopping any running port-forwards"
pkill -f "kubectl port-forward.*kubernetes-dashboard" || true
echo ""

# Delete the sample application
info "Removing sample nginx application"
kubectl delete -f nginx-demo.yaml --ignore-not-found
echo ""

# Delete the restricted user resources
info "Removing restricted user"
kubectl delete -f restricted-user.yaml --ignore-not-found
echo ""

# Delete the admin user
info "Removing admin user"
kubectl delete -f admin-user.yaml --ignore-not-found
echo ""

# Delete the dashboard itself
info "Removing Kubernetes Dashboard"
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
echo ""

# Delete any ingress if it was applied
kubectl delete -f dashboard-ingress.yaml --ignore-not-found &> /dev/null
echo ""

# Clean up the namespace
info "Deleting dashboard-demo namespace"
kubectl delete namespace dashboard-demo --ignore-not-found
echo ""

headline "Cleanup completed successfully!"
echo ""
info "All Kubernetes Dashboard resources have been removed from the cluster."
echo ""
