#!/bin/bash
# This script deploys the application to Kubernetes

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

headline "Deploying application to Kubernetes..."
echo ""

info "Applying Kubernetes manifests..."
kubectl apply -k ./kubernetes/
if [ $? -ne 0 ]; then
  error "Failed to apply manifests."
  exit 1
fi

echo ""
info "Checking rollout status..."
kubectl rollout status deployment/my-k8s-app
if [ $? -ne 0 ]; then
  error "Deployment rollout failed."
  exit 1
fi

echo ""
headline "Deployment successful. (Suggestion: To test hostname resolution, add 'demo.k8s.local' to your /etc/hosts)"
