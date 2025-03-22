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

headline "Kubernetes Load Balancing Workshop - Cleanup"
echo ""

# Check if we are in the right namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$CURRENT_NS" != "lb-demo" ]; then
  info "Switching to lb-demo namespace"
  kubectl config set-context --current --namespace=lb-demo
  echo ""
fi

# Delete all resources in order
info "Deleting Ingress resources"
kubectl delete ingress --all
echo ""

info "Deleting Services"
kubectl delete service --all
echo ""

info "Deleting Deployments"
kubectl delete deployment --all
echo ""

info "Deleting ConfigMaps"
kubectl delete configmap --all
echo ""

# Return to default namespace
info "Switching back to default namespace"
kubectl config set-context --current --namespace=default
echo ""

# Delete the namespace
info "Deleting lb-demo namespace"
kubectl delete namespace lb-demo
echo ""

headline "Cleanup Complete!"
info "All resources from the Kubernetes Load Balancing Workshop have been removed"
echo ""
