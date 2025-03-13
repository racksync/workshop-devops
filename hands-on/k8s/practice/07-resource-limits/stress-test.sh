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
print_color "headline" "Kubernetes Resource Limits - Stress Testing Script"
echo ""

# Check if we're in the right namespace
NAMESPACE=$(kubectl config view --minify | grep namespace | awk '{print $2}')
if [ "$NAMESPACE" != "resource-demo" ]; then
  print_color "warning" "You are not in the resource-demo namespace. Switching..."
  kubectl config set-context --current --namespace=resource-demo
  echo ""
fi

# Create pods with different resource configurations to observe behavior
print_color "headline" "Creating pods with different resource configurations"
echo ""

# 1. CPU-intensive pod
print_color "info" "Creating CPU-intensive pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cpu-stress-pod
  namespace: resource-demo
spec:
  containers:
  - name: cpu-stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        memory: "50Mi"
        cpu: "100m"
      limits:
        memory: "100Mi"
        cpu: "200m"
EOF
echo ""

# 2. Memory-increasing pod (gradually increases memory usage)
print_color "info" "Creating memory-increasing pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: memory-growth-pod
  namespace: resource-demo
spec:
  containers:
  - name: memory-growth
    image: polinux/stress
    command: ["/bin/sh", "-c"]
    args:
    - |
      for i in \$(seq 1 10); do
        echo "Allocating \${i}0MB memory..."
        stress --vm 1 --vm-bytes \${i}0M --vm-keep --timeout 30s
        sleep 5
      done
    resources:
      requests:
        memory: "50Mi"
        cpu: "100m"
      limits:
        memory: "200Mi"
        cpu: "200m"
EOF
echo ""

# 3. Pod without any resource limits (will use default from LimitRange)
print_color "info" "Creating pod without resource specifications (using LimitRange defaults)..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: no-limits-pod
  namespace: resource-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
EOF
echo ""

# Wait for pods to be created
print_color "info" "Waiting for pods to be created..."
sleep 10
echo ""

# Set up monitoring in a loop
print_color "headline" "Starting monitoring of pods resource usage"
print_color "info" "Press Ctrl+C to stop monitoring"
echo ""

# Function to monitor pods
monitor_pods() {
  while true; do
    clear
    print_color "headline" "Current Pod Status:"
    kubectl get pods
    echo ""
    
    print_color "headline" "Pod Resource Usage:"
    kubectl top pod
    echo ""
    
    print_color "headline" "Resource Quota Usage:"
    kubectl describe resourcequota namespace-quota | grep -A 10 "Used"
    echo ""
    
    print_color "headline" "Recent Events:"
    kubectl get events --sort-by=.metadata.creationTimestamp | tail -5
    echo ""
    
    print_color "info" "Updating every 5 seconds... (Press Ctrl+C to exit)"
    sleep 5
  done
}

# Note about hostname
print_color "info" "Note: If you need to access resources via a hostname, add the following to your /etc/hosts:"
print_color "info" "127.0.0.1   demo.k8s.local"
echo ""

# Start monitoring
monitor_pods
