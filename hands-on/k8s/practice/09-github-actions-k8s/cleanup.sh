#!/bin/bash
# This script cleans up the Kubernetes resources

# Define color output functions
info() {
  printf "\e[34m%s\e[0m\n" "$1"
}
error() {
  printf "\e[31m%s\e[0m\n" "$1"
}
headline() {
  printf "\e[36m%s\e[0m\n" "$1"
}

# Ensure kubectl is available
if ! command -v kubectl &> /dev/null; then
  error "kubectl is not installed. Please install kubectl."
  exit 1
fi

headline "Cleaning up Kubernetes resources..."
echo ""

info "Deleting Kubernetes manifests..."
kubectl delete -k ./kubernetes/
if [ $? -ne 0 ]; then
  error "Cleanup failed."
  exit 1
fi

echo ""
headline "Kubernetes resources cleaned up successfully."
