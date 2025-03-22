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

print_color "headline" "Kubernetes Multi-Container Pod Patterns Workshop Deployment"
print_color "info" "Creating namespace: pod-patterns"

kubectl create namespace pod-patterns

echo ""
print_color "info" "Setting current context to pod-patterns namespace"
kubectl config set-context --current --namespace=pod-patterns

echo ""
print_color "info" "Applying Sidecar Pattern example"
kubectl apply -f sidecar-pattern.yaml

echo ""
print_color "info" "Applying Ambassador Pattern example"
kubectl apply -f ambassador-pattern.yaml

echo ""
print_color "info" "Applying Adapter Pattern example"
kubectl apply -f adapter-pattern.yaml

echo ""
print_color "info" "Applying Init Container example"
kubectl apply -f init-container.yaml

echo ""
print_color "info" "Applying Practical Example (Web Application with Monitoring Sidecar)"
kubectl apply -f practical-example.yaml

echo ""
print_color "info" "Waiting for all pods to be ready..."
sleep 10

echo ""
print_color "headline" "Resources Status:"
echo ""
print_color "info" "Pods:"
kubectl get pods -n pod-patterns

echo ""
print_color "info" "Services:"
kubectl get services -n pod-patterns

echo ""
print_color "info" "ConfigMaps:"
kubectl get configmaps -n pod-patterns

echo ""
print_color "success" "Deployment completed successfully!"
print_color "info" "Run './test.sh' to test the deployed resources"
