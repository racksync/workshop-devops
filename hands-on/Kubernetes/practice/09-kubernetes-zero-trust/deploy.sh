#!/bin/bash

# Color definitions
function print_headline() {
  echo -e "\e[1;34m$1\e[0m"
}

function print_info() {
  echo -e "\e[0;32m$1\e[0m"
}

function print_error() {
  echo -e "\e[0;31m$1\e[0m"
}

function print_warning() {
  echo -e "\e[0;33m$1\e[0m"
}

print_headline "Zero-Trust Security Architecture Deployment"
print_headline "============================================"
echo ""

# Create namespace for zero-trust demo
print_info "Creating namespace for Zero-Trust demonstration"
kubectl create namespace zero-trust-demo
kubectl config set-context --current --namespace=zero-trust-demo
echo ""

# Install Istio with mTLS
print_info "Installing Istio with mTLS configuration"
kubectl apply -f istio-config.yaml
# Usually we would use istioctl, but for workshop purposes we'll use kubectl
echo ""

# Apply Network Policies
print_info "Applying Network Policies for micro-segmentation"
kubectl apply -f network-policies.yaml
echo ""

# Install and configure OPA Gatekeeper
print_info "Installing OPA Gatekeeper for policy enforcement"
kubectl apply -f gatekeeper-policies.yaml
echo ""

# Install HashiCorp Vault
print_info "Installing HashiCorp Vault for secure secrets management"
kubectl apply -f vault-config.yaml
echo ""

# Install SPIFFE/SPIRE for identity management
print_info "Installing SPIFFE/SPIRE for identity management"
kubectl apply -f spire-server.yaml
kubectl apply -f spire-agent.yaml
echo ""

# Install Falco for runtime threat detection
print_info "Installing Falco for runtime threat detection"
kubectl apply -f falco-config.yaml
echo ""

# Setup monitoring and logging platform
print_info "Setting up monitoring and logging platform"
kubectl apply -f monitoring-logging.yaml
echo ""

# Deploy sample secure application
print_info "Deploying sample secure application"
kubectl apply -f secure-app-deployment.yaml
echo ""

print_headline "Zero-Trust Deployment Complete!"
print_info "To test the setup, run: ./test.sh"
print_info "To clean up resources, run: ./cleanup.sh"
echo ""
print_warning "Note: Please add the following entry to your /etc/hosts file:"
print_warning "127.0.0.1 demo.k8s.local"
echo ""

exit 0
