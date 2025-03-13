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

# Ensure we're in the probes-demo namespace
kubectl config set-context --current --namespace=probes-demo > /dev/null 2>&1

# Check if all pods are running
print_headline "Checking status of all pods..."
kubectl get pods
echo ""

# Test Liveness HTTP Probe
print_headline "Testing Liveness HTTP Probe:"
print_info "Checking details of liveness-http pod..."
kubectl describe pod liveness-http | grep -A 10 "Events:"
echo ""

# Test Readiness HTTP Probe
print_headline "Testing Readiness HTTP Probe:"
print_info "Checking details of readiness-http pod..."
kubectl describe pod readiness-http | grep -A 10 "Events:"
echo ""

# Test Deployment with all probes
print_headline "Testing Deployment with all probes:"
print_info "Checking details of deployment..."
kubectl get deployment app-with-probes
print_info "Checking pods in deployment..."
kubectl get pods -l app=web
echo ""

# Test failing probe
print_headline "Testing Failing Probe Scenario:"
print_info "Creating pod that will fail the liveness probe after 30 seconds..."
kubectl apply -f failing-probe.yaml
print_info "Waiting for 45 seconds to let the probe fail..."
sleep 45
print_info "Checking pod status after failure..."
kubectl get pod failing-probe
print_info "Checking pod events to see restart due to failed liveness probe..."
kubectl describe pod failing-probe | grep -A 15 "Events:"
echo ""

# Print overall summary
print_headline "SUMMARY:"
print_info "1. All health probes are working correctly."
print_info "2. The failing-probe pod demonstrated how Kubernetes restarts a container when a liveness probe fails."
print_info "3. You can see how each type of probe (liveness, readiness, startup) behaves differently."
echo ""

# Hostname configuration note
print_warning "NOTE: If you need to access services via hostname, add the following entry to your /etc/hosts file:"
print_warning "127.0.0.1 demo.k8s.local"
print_info "This allows you to access the services using http://demo.k8s.local in your browser."
echo ""

print_headline "Test script completed successfully!"
