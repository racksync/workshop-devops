#!/bin/bash

# Color functions
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m✓ $1\033[0m"
}

function failure() {
  echo -e "\033[0;31m✗ $1\033[0m"
}

function warning() {
  echo -e "\033[0;33m$1\033[0m"
}

headline "Testing Kubernetes Dashboard Deployment"
echo ""

# Testing dashboard deployment
info "Checking if Kubernetes Dashboard is deployed"
if kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
  success "Dashboard deployment found"
else
  failure "Dashboard deployment not found. Please run ./deploy.sh first"
  exit 1
fi
echo ""

# Check if pods are running
info "Checking if Dashboard pods are running"
RUNNING_PODS=$(kubectl get pods -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
if [ "$RUNNING_PODS" == "Running" ]; then
  success "Dashboard pods are running"
else
  failure "Dashboard pods are not running. Current status: $RUNNING_PODS"
fi
echo ""

# Check service account
info "Checking admin user service account"
if kubectl get serviceaccount admin-user -n kubernetes-dashboard &> /dev/null; then
  success "Admin user service account exists"
else
  failure "Admin user service account not found"
fi
echo ""

# Check if sample application is deployed
info "Checking sample nginx application"
if kubectl get deployment nginx-demo -n dashboard-demo &> /dev/null; then
  success "Sample nginx application is deployed"
  
  # Check if nginx pods are running
  NGINX_PODS=$(kubectl get pods -n dashboard-demo -l app=nginx-demo -o jsonpath='{.items[*].status.phase}')
  if [[ $NGINX_PODS == *"Running"* ]]; then
    success "Sample nginx pods are running"
  else
    failure "Sample nginx pods are not running. Current status: $NGINX_PODS"
  fi
else
  warning "Sample nginx application is not deployed"
fi
echo ""

# Try to generate token and show partially
info "Testing token generation"
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null)
if [ -n "$TOKEN" ]; then
  success "Token generation successful"
  # Show first 15 characters of token
  TOKEN_PREFIX="${TOKEN:0:15}"
  info "Token preview: $TOKEN_PREFIX... (truncated for security)"
else
  failure "Could not generate token"
fi
echo ""

# Check if service is accessible via port-forward
info "Testing dashboard accessibility (starting port-forward)"
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 &>/dev/null &
PORT_FORWARD_PID=$!
sleep 3

if kill -0 $PORT_FORWARD_PID &>/dev/null; then
  success "Port-forward established successfully"
  info "Dashboard should be accessible at: https://localhost:8443"
  info "Stopping port-forward"
  kill $PORT_FORWARD_PID &>/dev/null
else
  failure "Failed to establish port-forward"
fi
echo ""

# Check if Ingress controller exists
info "Checking for Ingress Controller"
if kubectl get pods -A | grep -i ingress-controller &>/dev/null || kubectl get pods -A | grep -i ingress-nginx &>/dev/null; then
  success "Ingress controller found"
  
  # Get controller version information
  CONTROLLER_NS=$(kubectl get pods -A | grep -i ingress-controller | awk '{print $1}' | head -1 || \
                 kubectl get pods -A | grep -i ingress-nginx | awk '{print $1}' | head -1)
  CONTROLLER_POD=$(kubectl get pods -n $CONTROLLER_NS -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  
  if [ -n "$CONTROLLER_POD" ]; then
    info "Ingress controller pod: $CONTROLLER_POD in namespace $CONTROLLER_NS"
  fi
  
  # Check if dashboard ingress exists
  info "Checking dashboard ingress configuration"
  if kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard &>/dev/null; then
    success "Dashboard Ingress exists"
    
    # Check ingress class
    INGRESS_CLASS=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
    if [ -z "$INGRESS_CLASS" ]; then
      warning "No ingressClassName specified. This may cause routing issues."
      warning "Consider adding 'nginx' as ingressClassName."
    else
      success "Ingress class is set to: $INGRESS_CLASS"
    fi
    
    # Get ingress hostname
    INGRESS_HOST=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.spec.rules[0].host}')
    info "Ingress hostname: $INGRESS_HOST"
    
    # Check if hosts file contains entry
    if grep "$INGRESS_HOST" /etc/hosts &>/dev/null; then
      success "Hosts file entry for $INGRESS_HOST exists"
    else
      warning "No entry for $INGRESS_HOST in /etc/hosts file"
      warning "Add '127.0.0.1 $INGRESS_HOST' to /etc/hosts for local access"
    fi
    
    # Check TLS secret
    TLS_SECRET=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
    if [ -n "$TLS_SECRET" ] && kubectl get secret $TLS_SECRET -n kubernetes-dashboard &>/dev/null; then
      success "TLS secret '$TLS_SECRET' exists for the ingress"
    else
      warning "TLS secret for ingress not found or not properly configured"
      warning "This may cause SSL/TLS issues when accessing via HTTPS"
    fi
  else
    warning "Dashboard Ingress not found, you can deploy it with: kubectl apply -f dashboard-ingress.yaml"
  fi
else
  warning "No Ingress controller detected in cluster"
  warning "To use Ingress access, install a controller: kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
fi
echo ""

# Summary
headline "Test Summary"
echo ""
info "To access the Kubernetes Dashboard:"
echo "1. Start port-forwarding: kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
echo "2. Open in browser: https://localhost:8443"
echo "3. Use the token for authentication: kubectl -n kubernetes-dashboard create token admin-user"
echo ""

warning "Note: If you want to use Ingress with a custom hostname:"
echo "1. Ensure you have an Ingress controller installed"
echo "2. Apply dashboard-ingress.yaml: kubectl apply -f dashboard-ingress.yaml"
echo "3. Add to your /etc/hosts: 127.0.0.1 demo.k8s.local"
echo "4. Access the dashboard at: https://demo.k8s.local"
echo ""

info "For a guided access experience, run ./dashboard-access.sh"
info "For Ingress troubleshooting, run ./ingress-troubleshoot.sh"
echo ""
