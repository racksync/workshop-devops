#!/bin/bash

# Color function definitions
function print_info() {
    echo -e "\033[1;34m$1\033[0m"
}

function print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

function print_headline() {
    echo -e "\033[1;33m$1\033[0m"
}

# Save current namespace for later
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')

print_headline "Cleaning up Kubernetes Volumes workshop resources..."
echo ""

print_info "Deleting volume-demo namespace (this will delete all resources in the namespace)..."
kubectl delete namespace volume-demo
echo ""

# Reset context to previous namespace
if [ -n "$CURRENT_NS" ] && [ "$CURRENT_NS" != "volume-demo" ]; then
    kubectl config set-context --current --namespace=$CURRENT_NS
    print_info "Namespace context reset to: $CURRENT_NS"
else
    kubectl config set-context --current --namespace=default
    print_info "Namespace context reset to: default"
fi

echo ""
print_success "All resources have been cleaned up successfully!"
