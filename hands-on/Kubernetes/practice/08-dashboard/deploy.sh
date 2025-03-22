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

function warning() {
  echo -e "\033[0;33m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m✓ $1\033[0m"
}

headline "Deploying Kubernetes Dashboard"
echo ""

# Deploy the Kubernetes Dashboard
info "Installing Kubernetes Dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
echo ""

# Wait for dashboard to be ready
info "Waiting for Dashboard pods to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s
echo ""

# Create admin user
info "Creating admin user for Dashboard access"
kubectl apply -f admin-user.yaml
echo ""

# Create test namespace and restricted user
info "Creating test namespace and restricted user"
kubectl apply -f restricted-user.yaml
echo ""

# Deploy sample application
info "Deploying sample nginx application"
kubectl apply -f nginx-demo.yaml
echo ""
kubectl wait --for=condition=ready pod -l app=nginx-demo -n dashboard-demo --timeout=60s
echo ""

# Check for Ingress controller
info "Checking for Ingress Controller (optional)"
if kubectl get pods -A | grep -i ingress-controller &>/dev/null || kubectl get pods -A | grep -i ingress-nginx &>/dev/null; then
  success "Ingress controller found - you can enable Ingress access"
  
  # Ask if user wants to deploy ingress
  read -p "Do you want to deploy Dashboard Ingress? (y/n): " deploy_ingress
  if [[ "$deploy_ingress" == "y" || "$deploy_ingress" == "Y" ]]; then
    info "Deploying Dashboard Ingress"
    kubectl apply -f dashboard-ingress.yaml
    
    # Create self-signed certificate if needed
    if ! kubectl get secret dashboard-tls -n kubernetes-dashboard &>/dev/null; then
      info "Creating self-signed certificate for TLS..."
      # Create directory for certs if it doesn't exist
      mkdir -p certs
      # Generate self-signed certificate
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout certs/dashboard.key -out certs/dashboard.crt \
        -subj "/CN=demo.k8s.local/O=Kubernetes" \
        -addext "subjectAltName = DNS:demo.k8s.local"
        
      # Create kubernetes secret
      kubectl create secret tls dashboard-tls \
        --key certs/dashboard.key \
        --cert certs/dashboard.crt \
        -n kubernetes-dashboard
    fi
    
    # Check hosts file
    if ! grep "demo.k8s.local" /etc/hosts &>/dev/null; then
      warning "Please add this entry to your /etc/hosts file:"
      echo "127.0.0.1 demo.k8s.local"
    fi
    
    success "Dashboard Ingress deployed. Access at https://demo.k8s.local once /etc/hosts is configured"
  fi
else
  warning "No Ingress controller detected - using port-forward is recommended"
  warning "To install an Ingress controller, run: kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
fi
echo ""

# Display access information
headline "Kubernetes Dashboard Deployment Complete!"
echo ""
info "To access the dashboard, you have these options:"
echo ""
info "1. Use kubectl proxy:"
echo "   Run: kubectl proxy"
echo "   Then access: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
info "2. Use port-forward:"
echo "   Run: kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
echo "   Then access: https://localhost:8443"
echo ""
info "3. Use Ingress (if configured):"
echo "   Make sure 127.0.0.1 demo.k8s.local is in your /etc/hosts file"
echo "   Then access: https://demo.k8s.local"
echo ""

# Generate and display token
info "To generate an access token, run:"
echo "kubectl -n kubernetes-dashboard create token admin-user"
echo ""

warning "Note: For better security in production environments, consider:"
echo "- Creating restricted access roles instead of using cluster-admin"
echo "- Setting up proper TLS termination"
echo "- Implementing network policies to restrict dashboard access"
echo ""

info "To test the dashboard deployment, run: ./test.sh"
info "For guided access to the dashboard, run: ./dashboard-access.sh"
info "To clean up resources when finished, run: ./cleanup.sh"
echo ""
