#!/bin/bash

# Define color functions
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

# Start deployment process
headline "Starting Kubernetes Load Balancing Workshop Deployment"
echo ""

# Create namespace
info "Creating namespace lb-demo"
kubectl create namespace lb-demo
echo ""

# Set namespace context
info "Setting context to lb-demo namespace"
kubectl config set-context --current --namespace=lb-demo
echo ""

# Apply ConfigMaps
info "Applying ConfigMaps for version 1 and 2"
kubectl apply -f configmaps.yaml
echo ""

# Apply Deployments
info "Creating Deployments for version 1 and 2"
kubectl apply -f deployments.yaml
echo ""

# Wait for deployments to be ready
info "Waiting for deployments to be ready"
kubectl wait --for=condition=available --timeout=60s deployment/web-v1
kubectl wait --for=condition=available --timeout=60s deployment/web-v2
echo ""

# Apply Services
info "Creating ClusterIP Service for all versions"
kubectl apply -f service-clusterip.yaml
echo ""

info "Creating version-specific Services"
kubectl apply -f service-version-specific.yaml
echo ""

info "Creating Service with Session Affinity"
kubectl apply -f service-session-affinity.yaml
echo ""

info "Creating ExternalName Service"
kubectl apply -f service-externalname.yaml
echo ""

# Apply Ingress
info "Creating basic Ingress"
kubectl apply -f ingress-basic.yaml
echo ""

info "Creating path-based Ingress"
kubectl apply -f ingress-path-based.yaml
echo ""

info "Creating Canary Ingress (20% traffic to v2)"
kubectl apply -f ingress-canary.yaml
echo ""

# Display status
headline "Deployment Complete!"
info "The following resources have been created:"
echo ""

info "Pods:"
kubectl get pods
echo ""

info "Services:"
kubectl get services
echo ""

info "Ingresses:"
kubectl get ingress
echo ""

headline "Next Steps:"
info "1. Run './test.sh' to test load balancing functionality"
info "2. When finished, run './cleanup.sh' to remove all resources"
echo ""
