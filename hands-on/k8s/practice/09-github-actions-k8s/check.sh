#!/bin/bash
# This script performs an advanced test to check application responsiveness

# Define color output functions
info() {
  printf "\e[34m%s\e[0m\n" "$1"
}
error() {
  printf "\e[31m%s\e[0m\n" "$1"
}
headline() {
  printf "\e[36m%s\e[0m\n" "$1"
}

# Check if netcat is installed
if ! command -v nc &> /dev/null; then
  error "netcat (nc) is not installed. Please install it."
  exit 1
fi

headline "Performing advanced connectivity test..."
echo ""

# Get one pod from the deployment
pod=$(kubectl get pods -l app=my-k8s-app -o jsonpath='{.items[0].metadata.name}')
if [ -z "$pod" ]; then
  error "No pod found with label my-k8s-app."
  exit 1
fi

pod_ip=$(kubectl get pod "$pod" -o jsonpath='{.status.podIP}')
if [ -z "$pod_ip" ]; then
  error "Cannot fetch pod IP."
  exit 1
fi

echo ""
info "Testing connectivity on port 3000 for pod $pod ($pod_ip)..."
if nc -z "$pod_ip" 3000; then
  info "Port 3000 is open."
else
  error "Port 3000 is closed."
  exit 1
fi

echo ""
headline "Advanced connectivity test completed successfully."

