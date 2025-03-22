#!/bin/bash

# Color function definitions
function print_info() { echo -e "\033[0;34m${1}\033[0m"; }
function print_success() { echo -e "\033[0;32m${1}\033[0m"; }
function print_error() { echo -e "\033[0;31m${1}\033[0m"; }
function print_headline() { echo -e "\033[1;33m${1}\033[0m"; }

# Get desired replica count
if [ -z "$1" ]; then
    print_error "Please provide desired number of replicas"
    print_info "Usage: ./scale.sh <replica_count>"
    exit 1
fi

print_headline "Scaling deployment to $1 replicas"
kubectl scale deployment python-app -n python-demo --replicas=$1

echo ""

print_headline "Waiting for scaling to complete"
kubectl rollout status deployment/python-app -n python-demo

echo ""

print_headline "Current pod status"
kubectl get pods -n python-demo

echo ""

print_success "Scaling completed successfully"
