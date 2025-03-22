#!/bin/bash

# Functions for colored output
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;36m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

headline "Testing Kubernetes Custom Operator"
echo ""

# Check if namespace exists
if ! kubectl get namespace operator-demo &> /dev/null; then
  error "Namespace operator-demo does not exist. Please run deploy.sh first."
  exit 1
fi

# Set context to operator-demo namespace
kubectl config set-context --current --namespace=operator-demo
echo ""

# Check if operator is running
info "Checking if WebApp operator is running..."
if kubectl get deployment webapp-operator &> /dev/null; then
  success "WebApp operator is running"
  echo ""
  kubectl get deployment webapp-operator
else
  error "WebApp operator is not running!"
  exit 1
fi
echo ""

# Check if CRD is installed
info "Checking if WebApp CRD is installed..."
if kubectl get crd webapps.apps.example.com &> /dev/null; then
  success "WebApp CRD is installed"
  echo ""
  kubectl get crd webapps.apps.example.com
else
  error "WebApp CRD is not installed!"
  exit 1
fi
echo ""

# Check WebApp resources
info "Checking WebApp resources..."
if kubectl get webapps &> /dev/null; then
  success "WebApp resources found:"
  echo ""
  kubectl get webapps
else
  error "No WebApp resources found!"
fi
echo ""

# Check deployments created by the operator
info "Checking deployments created by the operator..."
kubectl get deployments -l app.kubernetes.io/managed-by=webapp-operator
echo ""

# Check services created by the operator
info "Checking services created by the operator..."
kubectl get services -l app.kubernetes.io/managed-by=webapp-operator
echo ""

# Check pods created by the operator
info "Checking pods..."
kubectl get pods
echo ""

# Get details about a specific WebApp
info "Getting details about sample-webapp..."
kubectl describe webapp sample-webapp
echo ""

headline "WebApp Operator Test Summary"
echo ""
success "If you see deployments, services and pods above, your operator is working correctly!"
echo ""
info "To access the web applications, you need to add the following entry to /etc/hosts:"
echo "127.0.0.1 demo.k8s.local"
echo ""
info "Then you can access the applications at:"
echo "http://demo.k8s.local:NODEPORT"
echo ""
info "Where NODEPORT is the port number you can find with:"
echo "kubectl get services -l app.kubernetes.io/managed-by=webapp-operator"
echo ""
