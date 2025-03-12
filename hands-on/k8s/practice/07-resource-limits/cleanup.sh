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
print_color "headline" "Kubernetes Resource Management Workshop - Cleanup Script"
echo ""

print_color "info" "Current namespace:"
kubectl config view --minify | grep namespace:
echo ""

print_color "info" "Deleting pods..."
kubectl delete pod --all -n resource-demo
echo ""

print_color "info" "Deleting deployments..."
kubectl delete deployment --all -n resource-demo
echo ""

print_color "info" "Deleting LimitRange..."
kubectl delete limitrange --all -n resource-demo
echo ""

print_color "info" "Deleting ResourceQuota..."
kubectl delete resourcequota --all -n resource-demo
echo ""

# Switch back to default namespace before deleting the resource-demo namespace
print_color "info" "Switching back to default namespace..."
kubectl config set-context --current --namespace=default
echo ""

print_color "info" "Deleting namespace: resource-demo"
kubectl delete namespace resource-demo
echo ""

print_color "success" "Cleanup completed successfully!"
echo ""
