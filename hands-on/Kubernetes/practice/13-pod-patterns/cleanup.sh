#!/bin/bash

# Function to display colored text
function print_color() {
    local color=$1
    local text=$2
    
    case $color in
        "info") echo -e "\033[0;36m${text}\033[0m" ;; # Cyan
        "success") echo -e "\033[0;32m${text}\033[0m" ;; # Green
        "error") echo -e "\033[0;31m${text}\033[0m" ;; # Red
        "warning") echo -e "\033[0;33m${text}\033[0m" ;; # Yellow
        "headline") echo -e "\033[1;34m${text}\033[0m" ;; # Blue bold
        *) echo "$text" ;;
    esac
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_color "error" "kubectl could not be found. Please install kubectl first."
    exit 1
fi

print_color "headline" "Cleaning up Kubernetes Multi-Container Pod Patterns Workshop resources"

echo ""
print_color "info" "Deleting all pods in pod-patterns namespace"
kubectl delete pods --all -n pod-patterns

echo ""
print_color "info" "Deleting all deployments in pod-patterns namespace"
kubectl delete deployments --all -n pod-patterns

echo ""
print_color "info" "Deleting all services in pod-patterns namespace"
kubectl delete services --all -n pod-patterns

echo ""
print_color "info" "Deleting all configmaps in pod-patterns namespace"
kubectl delete configmaps --all -n pod-patterns

echo ""
print_color "info" "Deleting pod-patterns namespace"
kubectl delete namespace pod-patterns

echo ""
print_color "info" "Setting context back to default namespace"
kubectl config set-context --current --namespace=default

echo ""
print_color "success" "Cleanup completed successfully!"
