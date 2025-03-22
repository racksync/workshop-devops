#!/bin/bash

# Script to debug Ingress connectivity issues

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for displaying messages
print_status() {
  echo -e "${YELLOW}$1${NC}"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

print_status "Starting Ingress Debugging..."
echo "============================================="

# 1. Check Ingress Controller installation
print_status "1. Checking Ingress Controller installation..."
echo ""

if kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress|traefik' &> /dev/null; then
  print_success "Ingress Controller found"
  echo "Ingress Controller pods:"
  echo ""
  kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress|traefik'
  echo ""
else
  print_error "No Ingress Controller found - please install one first"
  if kubectl get nodes -o wide | grep -q "minikube"; then
    print_status "For Minikube: minikube addons enable ingress"
  else
    print_status "For Docker Desktop/other: kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
  fi
  exit 1
fi

# 2. Check our specific Ingress resource
print_status "2. Checking our Ingress resource..."
echo ""
if kubectl get ingress nginx-ingress -n basic-demo &> /dev/null; then
  print_success "Ingress resource found"
  echo "Ingress details:"
  echo ""
  kubectl describe ingress nginx-ingress -n basic-demo
  echo ""
else
  print_error "Ingress resource not found in namespace basic-demo"
  exit 1
fi

# 3. Check if hosts file has the entry
print_status "3. Checking hosts file..."
echo ""
if grep -q "nginx.k8s.local" /etc/hosts; then
  print_success "Host entry found in /etc/hosts"
else
  print_error "Host entry not found - please add: 127.0.0.1 nginx.k8s.local"
fi

# 4. Test curl with Host header
print_status "4. Testing curl with Host header..."
echo ""
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --header "Host: nginx.k8s.local" http://localhost)

if [ "$HTTP_CODE" = "200" ]; then
  print_success "Connection successful with Host header (HTTP 200)"
else
  print_error "Connection failed with Host header (HTTP $HTTP_CODE)"
  print_status "Response body:"
  echo ""
  curl -s --header "Host: nginx.k8s.local" http://localhost
  echo ""
fi

# 5. Test curl directly to the hostname
print_status "5. Testing direct curl to hostname..."
echo ""
HTTP_CODE_DIRECT=$(curl -s -o /dev/null -w "%{http_code}" http://nginx.k8s.local)

if [ "$HTTP_CODE_DIRECT" = "200" ]; then
  print_success "Direct connection successful (HTTP 200)"
else
  print_error "Direct connection failed (HTTP $HTTP_CODE_DIRECT)"
  print_status "Response body:"
  echo ""
  curl -s http://nginx.k8s.local
  echo ""
fi

# 6. Check Ingress Controller logs
print_status "6. Checking Ingress Controller logs (last 20 lines)..."
NAMESPACE=$(kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress' | head -1 | awk '{print $1}')
POD_NAME=$(kubectl get pods -A | grep -E 'ingress-nginx|nginx-ingress' | grep controller | head -1 | awk '{print $2}')

if [ -n "$NAMESPACE" ] && [ -n "$POD_NAME" ]; then
  print_status "Found Ingress Controller pod: $POD_NAME in namespace: $NAMESPACE"
  echo ""
  kubectl logs -n "$NAMESPACE" "$POD_NAME" --tail=20
  echo ""
else
  print_error "Could not find Ingress Controller pod"
fi

# 7. Recommendations
echo "============================================="
print_status "Recommendations based on diagnostics:"
echo ""

echo "1. If curl with Host header works but direct access doesn't, check DNS resolution"
echo "2. If both tests fail with 404, check your Ingress configuration and NGINX pod setup"
echo "3. Try restarting your pods with: kubectl delete pod nginx-pod -n basic-demo && kubectl apply -f nginx-pod.yaml"
echo "4. If using Docker Desktop, make sure it's configured to use the kubernetes integration"
echo "5. For Minikube, ensure the Ingress addon is enabled and tunneling is working"
echo "6. Try accessing through the NodePort Service instead:"
echo "   kubectl patch service nginx-service -n basic-demo -p '{\"spec\":{\"type\": \"NodePort\"}}'"
echo "   kubectl get service nginx-service -n basic-demo"
echo "============================================="
