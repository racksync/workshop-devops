#!/bin/bash

# Color function definitions
function print_info() { echo -e "\033[0;34m${1}\033[0m"; }
function print_success() { echo -e "\033[0;32m${1}\033[0m"; }
function print_error() { echo -e "\033[0;31m${1}\033[0m"; }
function print_headline() { echo -e "\033[1;33m${1}\033[0m"; }

# Check if k8s.logmatt.com is in /etc/hosts
print_headline "Checking host configuration"
if ! grep -q "k8s.logmatt.com" /etc/hosts; then
    print_error "Please add the following line to /etc/hosts:"
    print_info "127.0.0.1 k8s.logmatt.com"
    exit 1
fi

echo ""

# Check deployment status
print_headline "Checking deployment status"
kubectl get pods -n python-demo

echo ""

# Check service status
print_headline "Checking service status"
kubectl get svc -n python-demo

echo ""

# Test application endpoint
print_headline "Testing application endpoint"
curl -s http://k8s.logmatt.com

echo ""

print_success "Test completed"
