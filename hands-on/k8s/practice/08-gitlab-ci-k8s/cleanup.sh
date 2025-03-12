#!/bin/bash

# Function definitions for colored output
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
    echo ""
}

function print_info() {
    echo -e "\033[0;34m$1\033[0m"
    echo ""
}

function print_success() {
    echo -e "\033[0;32m$1\033[0m"
    echo ""
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
    echo ""
}

function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
    echo ""
}

# Script starts here
print_headline "GitLab CI/CD for Kubernetes Workshop - Cleanup"

# Set directory variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/my-k8s-app"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if namespace exists
if kubectl get namespace gitlab-demo &> /dev/null; then
    print_info "Removing all resources in the gitlab-demo namespace"

    print_info "Deleting Ingresses"
    kubectl delete ingress --all -n gitlab-demo
    echo ""
    
    print_info "Deleting all Deployments"
    kubectl delete deployments --all -n gitlab-demo
    echo ""
    
    print_info "Deleting all Services"
    kubectl delete services --all -n gitlab-demo
    echo ""
    
    print_info "Deleting all ConfigMaps"
    kubectl delete configmaps --all -n gitlab-demo
    echo ""
    
    print_info "Deleting all Secrets"
    kubectl delete secrets --all -n gitlab-demo
    echo ""
    
    print_info "Deleting the gitlab-demo namespace"
    kubectl delete namespace gitlab-demo
    echo ""
    
    print_info "Resetting kubectl context to default namespace"
    kubectl config set-context --current --namespace=default
    echo ""
    
    print_success "Cleanup completed! All resources have been removed."
else
    print_warning "The gitlab-demo namespace does not exist. Nothing to clean up."
fi

# Clean up local project files (optional)
if [ -d "$PROJECT_DIR" ]; then
    print_info "Would you like to remove the local project files? (y/n)"
    read -r answer
    
    if [[ $answer =~ ^[Yy]$ ]]; then
        print_info "Removing local project files"
        rm -rf "$PROJECT_DIR"
        echo ""
        print_success "Local project files removed."
    else
        print_info "Local project files preserved."
    fi
fi

print_info "If you added demo.k8s.local to your /etc/hosts file, you may want to remove it manually."
echo ""

print_success "Workshop environment cleanup completed!"
