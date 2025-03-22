#!/bin/bash

# Function to display colored text
print_color() {
  local color=$1
  local text=$2
  
  case $color in
    "info") echo -e "\033[36m$text\033[0m" ;;    # Cyan color for info
    "success") echo -e "\033[32m$text\033[0m" ;; # Green color for success
    "error") echo -e "\033[31m$text\033[0m" ;;   # Red color for error
    "warning") echo -e "\033[33m$text\033[0m" ;; # Yellow color for warning
    "headline") echo -e "\033[1;35m$text\033[0m" ;; # Bold purple for headlines
  esac
}

# Print headline for the script
print_color "headline" "Kubernetes Resource Management Workshop - Deployment Script"
echo ""

# Create namespace for the workshop
print_color "info" "Creating namespace: resource-demo"
kubectl create namespace resource-demo
echo ""

# Switch to the new namespace
print_color "info" "Switching to namespace: resource-demo"
kubectl config set-context --current --namespace=resource-demo
echo ""

# Deploy the simple pod with resource requests and limits
print_color "info" "Creating simple pod with resource requests and limits"
kubectl apply -f simple-pod.yaml
echo ""

# Deploy the resource-hungry pod
print_color "info" "Creating resource-hungry pod"
kubectl apply -f resource-hungry-pod.yaml
echo ""

# Deploy the deployment with resource settings
print_color "info" "Creating deployment with resource settings"
kubectl apply -f resource-deployment.yaml
echo ""

# Create LimitRange
print_color "info" "Creating LimitRange for default resource settings"
kubectl apply -f limit-range.yaml
echo ""

# Create ResourceQuota
print_color "info" "Creating ResourceQuota to limit namespace resources"
kubectl apply -f resource-quota.yaml
echo ""

# Wait for resources to be ready
print_color "info" "Waiting for resources to be ready..."
sleep 5
echo ""

# Display created resources
print_color "headline" "Resources created successfully:"
echo ""
print_color "info" "Pods:"
kubectl get pods
echo ""
print_color "info" "Deployments:"
kubectl get deployments
echo ""
print_color "info" "LimitRange:"
kubectl get limitrange
echo ""
print_color "info" "ResourceQuota:"
kubectl get resourcequota
echo ""

print_color "success" "Deployment complete! You can now explore the resources."
print_color "info" "Run './test.sh' to test resource limits behavior."
echo ""
