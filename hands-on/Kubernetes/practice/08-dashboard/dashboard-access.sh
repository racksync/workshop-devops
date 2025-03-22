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

function user_prompt() {
  echo -e "\033[0;36m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m✓ $1\033[0m"
}

function failure() {
  echo -e "\033[0;31m✗ $1\033[0m"
}

# Check if dashboard is running
if ! kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
  error "Kubernetes Dashboard is not deployed. Please run ./deploy.sh first."
  exit 1
fi

headline "Kubernetes Dashboard Access Helper"
echo ""

# Menu for access options
info "Please select your preferred access method:"
echo "1. kubectl proxy (http access)"
echo "2. port-forward (https access)"
echo "3. ingress (if configured)"
echo "q. quit"
echo ""
user_prompt "Enter your choice (1-3 or q): "
read -r choice
echo ""

case $choice in
  1)
    headline "Starting kubectl proxy..."
    info "This will run until you press Ctrl+C"
    echo ""
    
    # Generate token
    TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
    
    info "Access the dashboard at:"
    echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
    echo ""
    info "Use this token to log in:"
    echo "$TOKEN"
    echo ""
    
    # Start proxy
    kubectl proxy
    ;;
    
  2)
    headline "Starting port-forward..."
    info "This will run until you press Ctrl+C"
    echo ""
    
    # Generate token
    TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
    
    info "Access the dashboard at:"
    echo "https://localhost:8443"
    echo ""
    warning "Your browser will warn about an invalid certificate. This is expected."
    echo "You can proceed by clicking 'Advanced' and 'Accept Risk'"
    echo ""
    info "Use this token to log in:"
    echo "$TOKEN"
    echo ""
    
    # Start port-forward
    kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443
    ;;
    
  3)
    headline "Accessing via Ingress"
    echo ""
    
    # Check if ingress controller exists
    if ! kubectl get pods -A | grep -i ingress-controller &>/dev/null && ! kubectl get pods -A | grep -i ingress-nginx &>/dev/null; then
      warning "No Ingress controller detected in your cluster"
      info "Installing NGINX Ingress Controller..."
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
      
      echo ""
      info "Waiting for Ingress controller to be ready (this might take a minute)..."
      kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s
      echo ""
    else
      success "Ingress controller found in the cluster"
    fi
    
    # Check if ingress is deployed
    if ! kubectl get ingress kubernetes-dashboard-ingress -n kubernetes-dashboard &> /dev/null; then
      info "Dashboard Ingress not found. Deploying now..."
      kubectl apply -f dashboard-ingress.yaml
      echo ""
    else
      success "Dashboard Ingress already configured"
    fi
    
    # Check if TLS secret exists
    if ! kubectl get secret dashboard-tls -n kubernetes-dashboard &> /dev/null; then
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
      
      success "TLS secret created successfully"
    else
      success "TLS secret already exists"
    fi
    
    # Check if basic auth is configured
    if ! kubectl get secret basic-auth -n kubernetes-dashboard &> /dev/null; then
      info "Setting up basic authentication..."
      # Create a temporary file with credentials
      echo "admin:$(openssl passwd -apr1 dashboard)" > auth
      # Create kubernetes secret
      kubectl create secret generic basic-auth \
        --from-file=auth \
        -n kubernetes-dashboard
      # Remove temporary file
      rm auth
      success "Basic authentication configured"
      info "Username: admin, Password: dashboard"
    else
      success "Basic authentication already configured"
    fi
    
    # Generate token
    TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
    
    # Check hosts file
    if ! grep "demo.k8s.local" /etc/hosts &>/dev/null; then
      warning "Please add this entry to your /etc/hosts file:"
      echo "127.0.0.1 demo.k8s.local"
      warning "Run: sudo -- sh -c \"echo '127.0.0.1 demo.k8s.local' >> /etc/hosts\""
    else 
      success "Host entry for demo.k8s.local found in /etc/hosts file"
    fi
    
    echo ""
    info "Access the dashboard at:"
    echo "https://demo.k8s.local"
    echo ""
    warning "You'll need to accept the self-signed certificate warning."
    echo ""
    info "Use basic auth to access the Ingress:"
    echo "Username: admin"
    echo "Password: dashboard"
    echo ""
    info "Then use this token for dashboard login:"
    echo "$TOKEN"
    echo ""
    
    # Optional: Setup port-forward to ingress controller for local access
    info "Setting up port forwarding to NGINX Ingress controller..."
    kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 443:443 &
    INGRESS_PID=$!
    
    info "Port forwarding active. Press Enter to stop and return to menu."
    read
    kill $INGRESS_PID &>/dev/null
    ;;
    
  q|Q)
    info "Exiting..."
    exit 0
    ;;
    
  *)
    error "Invalid option. Exiting."
    exit 1
    ;;
esac

echo ""
headline "Thank you for using the Kubernetes Dashboard!"
echo ""
