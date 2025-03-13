#!/bin/bash

# Define color functions
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
}

function print_info() {
    echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
}

# Create namespace and set context
print_headline "Creating 'probes-demo' namespace..."
kubectl create namespace probes-demo

print_headline "Setting current context to 'probes-demo' namespace..."
kubectl config set-context --current --namespace=probes-demo

echo ""

# Create Liveness HTTP Probe example
print_headline "Creating Pod with Liveness HTTP Probe..."
kubectl apply -f liveness-http-probe.yaml
echo ""

# Create Readiness HTTP Probe example
print_headline "Creating Pod with Readiness HTTP Probe..."
kubectl apply -f readiness-http-probe.yaml
echo ""

# Create Startup Probe example
print_headline "Creating Pod with Startup Probe..."
kubectl apply -f startup-probe.yaml
echo ""

# Create Exec Probe example
print_headline "Creating Pod with Exec Probe..."
kubectl apply -f exec-probe.yaml
echo ""

# Create TCP Socket Probe example
print_headline "Creating Pod with TCP Socket Probe..."
kubectl apply -f tcp-probe.yaml
echo ""

# Create Deployment with all types of Probes
print_headline "Creating Deployment with all types of Probes..."
kubectl apply -f deployment-with-probes.yaml
echo ""

# Check the status of created resources
print_headline "Checking the status of created resources..."
kubectl get pods -o wide
echo ""

print_info "Setup completed! All Pods and Deployments have been created."
print_info "Please run './test.sh' to test the behavior of the health probes."
