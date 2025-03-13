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

function failure() {
  echo -e "\033[0;31m✗ $1\033[0m"
}

headline "Kubernetes Dashboard Ingress Troubleshooting"
echo ""

# Check if Ingress Controller is installed
info "Checking for Ingress Controller"
if kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller 2>/dev/null | grep Running &>/dev/null; then
  success "NGINX Ingress Controller is installed and running"
  
  # Get Ingress Controller version and pod details
  CONTROLLER_POD=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}')
  echo "  Pod name: $CONTROLLER_POD"
  
  VERSION=$(kubectl exec -n ingress-nginx $CONTROLLER_POD -- /nginx-ingress-controller --version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
  echo "  Controller version: $VERSION"
else
  failure "NGINX Ingress Controller is not installed or not running"
  
  info "Installing NGINX Ingress Controller..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
  
  info "Waiting for Ingress Controller to be ready (this might take a minute or two)..."
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=180s
fi
echo ""

# Check if Dashboard Ingress exists
info "Checking Dashboard Ingress configuration"
if kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard &>/dev/null; then
  success "Dashboard Ingress exists"
  
  # Get Ingress details
  INGRESS_IP=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  INGRESS_HOST=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.spec.rules[0].host}')
  
  echo "  Host: $INGRESS_HOST"
  echo "  IP: ${INGRESS_IP:-Not assigned yet}"
  
  # If there's no IP, this could indicate a problem with the Ingress controller
  if [ -z "$INGRESS_IP" ]; then
    warning "No IP assigned to Ingress. This could indicate an issue with the Ingress Controller."
  fi
  
  # Check ingress class
  INGRESS_CLASS=$(kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard -o jsonpath='{.spec.ingressClassName}')
  if [ -z "$INGRESS_CLASS" ]; then
    warning "No ingressClassName specified. Adding 'nginx' as ingressClassName..."
    kubectl patch ingress kubernetes-dashboard-ingress -n kubernetes-dashboard --type=json \
      -p='[{"op": "add", "path": "/spec/ingressClassName", "value": "nginx"}]'
  else
    echo "  Ingress class: $INGRESS_CLASS"
  fi
else
  failure "Dashboard Ingress not found"
  info "Recreating the Dashboard Ingress..."
  kubectl apply -f dashboard-ingress.yaml
fi
echo ""

# Check TLS secret
info "Checking TLS secret for Ingress"
if kubectl get secret dashboard-tls -n kubernetes-dashboard &>/dev/null; then
  success "TLS Secret exists"
else
  failure "TLS Secret not found"
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
echo ""

# Check if hosts file is configured
info "Checking hosts file configuration"
if grep "demo.k8s.local" /etc/hosts &>/dev/null; then
  success "Host entry found in /etc/hosts"
  HOSTS_IP=$(grep "demo.k8s.local" /etc/hosts | awk '{print $1}')
  echo "  Mapped to IP: $HOSTS_IP"
else
  failure "No entry for demo.k8s.local in /etc/hosts"
  warning "Add this entry to your /etc/hosts file:"
  echo "  127.0.0.1 demo.k8s.local"
  
  # Prompt to add the entry
  read -p "Would you like to add this entry now? (requires sudo) [y/N]: " ADD_HOSTS
  if [[ "$ADD_HOSTS" =~ ^[Yy]$ ]]; then
    echo "127.0.0.1 demo.k8s.local" | sudo tee -a /etc/hosts > /dev/null
    success "Entry added to /etc/hosts"
  fi
fi
echo ""

# Check dashboard service
info "Checking Dashboard service"
if kubectl get service kubernetes-dashboard -n kubernetes-dashboard &>/dev/null; then
  success "Dashboard service exists"
  
  # Check service details
  SVC_PORT=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].port}')
  SVC_TARGET_PORT=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].targetPort}')
  
  echo "  Port: $SVC_PORT"
  echo "  Target Port: $SVC_TARGET_PORT"
else
  failure "Dashboard service not found"
  error "The Kubernetes Dashboard service is missing. Please reinstall the dashboard."
fi
echo ""

# Test connectivity to the dashboard service
info "Testing direct connectivity to Dashboard service"
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 &
PORT_FORWARD_PID=$!
sleep 3

if curl -k https://localhost:8443 &>/dev/null; then
  success "Dashboard is accessible via port-forward"
else
  failure "Dashboard is not accessible via port-forward"
  warning "There might be an issue with the Dashboard deployment itself."
fi

# Kill the port-forward process
kill $PORT_FORWARD_PID &>/dev/null
wait $PORT_FORWARD_PID 2>/dev/null
echo ""

# Set up port forwarding for Ingress controller
headline "Setting up port forwarding to access the Dashboard"
echo ""
info "I'll set up port forwarding for the Ingress controller."
info "This will allow you to access the Dashboard at https://demo.k8s.local"
echo ""
info "Starting port-forward to NGINX Ingress controller..."
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 443:443 &
INGRESS_PID=$!
sleep 3

if kill -0 $INGRESS_PID 2>/dev/null; then
  success "Port-forward to Ingress controller is active"
  echo ""
  info "Now try accessing the Dashboard at:"
  echo "  https://demo.k8s.local"
  echo ""
  info "When finished, press Enter to stop port forwarding."
  read
  kill $INGRESS_PID &>/dev/null
  wait $INGRESS_PID 2>/dev/null
else
  failure "Failed to set up port-forward to Ingress controller"
fi
echo ""

# Summary and next steps
headline "Troubleshooting Summary"
echo ""
info "If you're still experiencing issues:"
echo "1. Make sure your Ingress controller is properly installed and running"
echo "2. Check that your hosts file has the correct entry: 127.0.0.1 demo.k8s.local"
echo "3. Try accessing the dashboard directly via port-forward: kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
echo "4. Check the logs of the Ingress controller for any errors: kubectl logs -n ingress-nginx deployment/ingress-nginx-controller"
echo ""
info "For a guided access experience, run ./dashboard-access.sh and choose option 3 for Ingress access"
echo ""

# Make script executable
chmod +x ingress-troubleshoot.sh
