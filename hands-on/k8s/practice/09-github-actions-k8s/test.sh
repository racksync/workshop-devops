#!/bin/bash
# This script tests the deployed application and Kubernetes configurations

# Define color output functions
info() {
  printf "\e[34m%s\e[0m\n" "$1"
}
error() {
  printf "\e[31m%s\e[0m\n" "$1"
}
success() {
  printf "\e[32m%s\e[0m\n" "$1"
}
headline() {
  printf "\e[36m%s\e[0m\n" "$1"
}

# Ensure kubectl is available
if ! command -v kubectl &> /dev/null; then
  error "kubectl is not installed. Please install kubectl."
  exit 1
fi

headline "Testing Kubernetes deployment..."
echo ""

info "Please ensure 'demo.k8s.local' is added to your /etc/hosts for hostname resolution."
echo ""

info "Verifying deployment status..."
availableReplicas=$(kubectl get deployment my-k8s-app -o jsonpath='{.status.availableReplicas}')
if [ "$availableReplicas" == "3" ]; then
  success "Deployment is running with 3 replicas."
else
  error "Deployment not as expected. Available replicas: $availableReplicas."
  exit 1
fi

echo ""
info "Verifying service configuration..."
serviceType=$(kubectl get service my-k8s-app -o jsonpath='{.spec.type}')
if [ "$serviceType" == "ClusterIP" ]; then
  success "Service type is ClusterIP."
else
  error "Service type incorrect: $serviceType."
  exit 1
fi

echo ""
headline "Test completed successfully."
