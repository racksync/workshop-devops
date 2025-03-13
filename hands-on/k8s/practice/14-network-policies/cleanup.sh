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
print_headline "Network Policies Workshop - Cleanup Script"
print_info "This script will remove all resources created for the Network Policies demonstration."
echo ""

# Store current namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')

# Check if we're in the right namespace
if [ "$CURRENT_NS" != "netpol-demo" ]; then
  print_info "Currently not in netpol-demo namespace, switching context"
  kubectl config set-context --current --namespace=netpol-demo
  echo ""
fi

# Remove network policies
print_info "Removing network policies"
kubectl delete networkpolicy --all
echo ""

# Remove services
print_info "Removing services"
kubectl delete svc --all
echo ""

# Remove deployments
print_info "Removing deployments"
kubectl delete deployment --all
echo ""

# Remove pods
print_info "Removing pods"
kubectl delete pod --all --grace-period=0 --force
echo ""

# Switch back to default namespace
print_info "Switching back to default namespace"
kubectl config set-context --current --namespace=default
echo ""

# Delete namespace
print_info "Deleting netpol-demo namespace"
kubectl delete namespace netpol-demo
if [ $? -eq 0 ]; then
  print_success "Namespace deleted successfully"
else
  print_error "Failed to delete namespace"
  exit 1
fi
echo ""

# Summary
print_headline "Cleanup Complete!"
print_success "All resources from the Network Policies workshop have been removed."
echo ""
