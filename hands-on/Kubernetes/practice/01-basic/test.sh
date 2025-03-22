#!/bin/bash

# Script for testing Kubernetes resources of NGINX Demo

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for displaying status messages
print_status() {
  echo -e "${YELLOW}$1${NC}"
}

# Function for displaying success messages
print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Function for displaying error messages
print_error() {
  echo -e "${RED}$1${NC}"
}

# Function for checking errors
check_error() {
  if [ $? -ne 0; then
    print_error "$1"
    return 1
  fi
  return 0
}

print_status "Starting NGINX Demo tests on Kubernetes..."

# Check if the namespace exists
print_status "Checking if namespace 'basic-demo' exists..."
if ! kubectl get namespace basic-demo &> /dev/null; then
  print_error "Namespace 'basic-demo' not found. Please run deploy.sh first."
  exit 1
fi
print_success "Namespace 'basic-demo' exists"

# Test 1: Check if Pod is running properly
print_status "1. Checking if NGINX Pod is running..."
POD_STATUS=$(kubectl get pod nginx-pod -n basic-demo -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" == "Running" ]; then
  print_success "NGINX Pod is running"
else
  print_error "NGINX Pod is not running (status: $POD_STATUS)"
  exit 1
fi

# Test 2: Test accessing Pod through Service
print_status "2. Testing access to NGINX Pod through Service..."
print_status "Starting port-forward in background..."
kubectl port-forward service/nginx-service 8080:80 -n basic-demo &> /dev/null &
PORT_FORWARD_PID=$!
# Give it a moment to start
sleep 2

print_status "Sending HTTP request to localhost:8080..."
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
HTTP_CONTENT=$(curl -s http://localhost:8080 | head -15)
kill $PORT_FORWARD_PID &> /dev/null

if [ "$HTTP_RESPONSE" == "200" ]; then
  print_success "Successfully accessed NGINX through Service (HTTP 200)"
  print_status "First 15 lines of the response:"
  echo "$HTTP_CONTENT"
else
  print_error "Failed to access NGINX through Service (HTTP $HTTP_RESPONSE)"
  exit 1
fi

# Test 3: Check logs of container in Pod
print_status "3. Checking logs of NGINX container..."
LOGS=$(kubectl logs nginx-pod -n basic-demo 2>/dev/null)
if [ -n "$LOGS" ]; then
  print_success "Successfully retrieved logs from NGINX container"
  print_status "Last few lines of the logs:"
  echo "$LOGS" | tail -5
else
  print_error "Failed to retrieve logs from NGINX container"
  exit 1
fi

# Test 4: Test running commands inside the container
print_status "4. Testing execution of commands inside NGINX container..."
VERSION=$(kubectl exec -n basic-demo nginx-pod -- nginx -v 2>/dev/null)
if [ $? -eq 0 ]; then
  print_success "Successfully executed command inside NGINX container"
  print_status "$VERSION"
else
  print_error "Failed to execute command inside NGINX container"
  exit 1
fi

# Test 5: Check Ingress configuration
print_status "5. Checking Ingress configuration..."
if ! kubectl get ingress nginx-ingress -n basic-demo &> /dev/null; then
  print_error "Ingress 'nginx-ingress' not found. Please check your deployment."
  exit 1
fi
print_success "Ingress 'nginx-ingress' exists"
print_status "Ingress details:"
kubectl describe ingress nginx-ingress -n basic-demo | grep -E 'Host|Path|Backend|Rules'

# Test 6: Check if Ingress Controller is installed
print_status "6. Checking if Ingress Controller is installed..."
INGRESS_CONTROLLER_EXISTS=false
if kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress|traefik|ambassador|contour|kong|istio-ingressgateway' &> /dev/null; then
  print_success "Ingress Controller appears to be installed"
  print_status "Ingress Controller pods:"
  kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress|traefik|ambassador|contour|kong|istio-ingressgateway'
  INGRESS_CONTROLLER_EXISTS=true
else
  print_error "No Ingress Controller detected. You need to install one to use Ingress resources."
  print_status "Your cluster is missing an Ingress Controller, which is required for Ingress resources to work."
  print_status "This is why you cannot connect to nginx.k8s.local even though you've added it to your hosts file."
  
  # Detect Kubernetes environment
  if kubectl get nodes -o wide | grep -q "minikube"; then
    print_status "Detected Minikube. Enable the Ingress addon with:"
    print_status "minikube addons enable ingress"
  elif kubectl get nodes -o wide | grep -q "docker-desktop"; then
    print_status "Detected Docker Desktop. Install the NGINX Ingress Controller with:"
    print_status "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
  else
    print_status "Install the NGINX Ingress Controller with:"
    print_status "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
  fi
  
  print_status "After installing, wait for the controller to be ready:"
  print_status "kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s"
fi

# Test 7: Check hosts file for nginx.k8s.local entry
print_status "7. Checking if nginx.k8s.local is in your hosts file..."
if grep -q "nginx.k8s.local" /etc/hosts; then
  print_success "Found nginx.k8s.local in /etc/hosts file"
else
  print_error "nginx.k8s.local entry not found in /etc/hosts file"
  print_status "Please add the following line to your /etc/hosts file:"
  print_status "127.0.0.1 nginx.k8s.local"
fi

# Test 8: Test direct connection to Ingress (if controller exists)
if [ "$INGRESS_CONTROLLER_EXISTS" = true ]; then
  print_status "8. Testing direct connection to Ingress..."
  # Try curl with Host header first (more reliable)
  print_status "Sending HTTP request to Ingress with Host header..."
  INGRESS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --header "Host: nginx.k8s.local" http://localhost)
  INGRESS_CONTENT=$(curl -s --header "Host: nginx.k8s.local" http://localhost | head -15)
  
  if [ "$INGRESS_RESPONSE" == "200" ]; then
    print_success "Successfully accessed NGINX through Ingress with Host header (HTTP 200)"
    print_status "First 15 lines of the response:"
    echo "$INGRESS_CONTENT"
  else
    print_error "Could not access NGINX through Ingress with Host header (HTTP $INGRESS_RESPONSE)"
    print_status "Trying to connect directly to nginx.k8s.local..."
    DIRECT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://nginx.k8s.local)
    DIRECT_CONTENT=$(curl -s http://nginx.k8s.local | head -15)
    
    if [ "$DIRECT_RESPONSE" == "200" ]; then
      print_success "Successfully accessed NGINX through direct hostname (HTTP 200)"
      print_status "First 15 lines of the response:"
      echo "$DIRECT_CONTENT"
    else
      print_error "Could not access NGINX through direct hostname (HTTP $DIRECT_RESPONSE)"
      print_status "Response body (might contain error details):"
      curl -s http://nginx.k8s.local
      print_status "Check that your Ingress Controller is properly configured."
    fi
  fi
else
  print_status "8. Skipping Ingress direct connection test (no Ingress Controller found)"
fi

print_success "All tests completed!"
print_status "NGINX Demo is working properly through Service port-forward."
echo ""
print_status "Troubleshooting nginx.k8s.local connectivity:"
echo "1. Verify hosts file contains: 127.0.0.1 nginx.k8s.local (VERIFIED)"
if [ "$INGRESS_CONTROLLER_EXISTS" = true ]; then
  echo "2. Ensure Ingress Controller is properly installed and running (VERIFIED)"
else
  echo "2. Install an Ingress Controller (MISSING - see instructions above)"
fi
echo "3. After installation, verify the Ingress Controller is ready:"
echo "   kubectl get pods -n ingress-nginx"
echo "4. Check Ingress Controller logs:"
echo "   kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller"
echo "5. Verify the Ingress resource is properly configured:"
echo "   kubectl describe ingress nginx-ingress -n basic-demo"
echo ""
print_status "To test with curl:"
echo "curl -v --header 'Host: nginx.k8s.local' http://localhost"
echo ""
print_status "Try direct connection after Ingress Controller is installed:"
echo "curl -v http://nginx.k8s.local"
echo ""
