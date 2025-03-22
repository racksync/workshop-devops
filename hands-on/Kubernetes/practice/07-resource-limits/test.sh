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
print_color "headline" "Kubernetes Resource Management Workshop - Testing Script"
echo ""

# Check if we're in the right namespace
print_color "info" "Checking current namespace..."
NAMESPACE=$(kubectl config view --minify | grep namespace | awk '{print $2}')
if [ "$NAMESPACE" != "resource-demo" ]; then
  print_color "warning" "You are not in the resource-demo namespace. Switching..."
  kubectl config set-context --current --namespace=resource-demo
  echo ""
fi

# Check if pods are running
print_color "info" "Checking pod status..."
kubectl get pods
echo ""

# Display resource usage of pods
print_color "headline" "Resource Usage of Pods:"
kubectl top pod
echo ""

print_color "headline" "Pod Details:"
print_color "info" "Checking details of simple-pod:"
kubectl describe pod simple-pod | grep -A 15 "Containers:"
echo ""

print_color "info" "Checking details of memory-hungry-pod:"
kubectl describe pod memory-hungry-pod | grep -A 15 "Containers:"
echo ""

# Check resource quota usage
print_color "headline" "Resource Quota Usage:"
kubectl describe resourcequota namespace-quota
echo ""

# Test exceeding resource limits
print_color "headline" "Testing Pod that Exceeds Memory Limits:"
print_color "info" "Creating pod that will exceed memory limits..."
kubectl apply -f exceed-limits-pod.yaml
echo ""

print_color "info" "Waiting for the pod to start and potentially hit OOM..."
sleep 10
echo ""

print_color "info" "Checking status of exceed-memory-pod:"
kubectl get pod exceed-memory-pod
echo ""

print_color "info" "Checking events related to exceed-memory-pod:"
kubectl describe pod exceed-memory-pod | grep -A 15 "Events:"
echo ""

# Test resource quota enforcement by creating a pod that would exceed the quota
print_color "headline" "Testing Resource Quota Enforcement:"
print_color "info" "Creating a deployment that would exceed our quota..."

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quota-exceed-test
  namespace: resource-demo
spec:
  replicas: 5
  selector:
    matchLabels:
      app: quota-test
  template:
    metadata:
      labels:
        app: quota-test
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            memory: "256Mi"
            cpu: "300m"
          limits:
            memory: "512Mi"
            cpu: "500m"
EOF
echo ""

print_color "info" "Waiting for deployment to attempt creation..."
sleep 5
echo ""

print_color "info" "Checking deployment status:"
kubectl get deployment quota-exceed-test
echo ""

print_color "info" "Checking pods of the deployment:"
kubectl get pods -l app=quota-test
echo ""

print_color "info" "Checking events for quota violations:"
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i "quota\|exceed" | tail -5
echo ""

print_color "success" "Testing complete!"
print_color "info" "You can run './cleanup.sh' to remove all resources when done."
echo ""
