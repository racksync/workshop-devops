#!/bin/bash

# Define color functions
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

function section() {
  echo -e "\033[0;36m$1\033[0m"
}

function warning() {
  echo -e "\033[0;33m$1\033[0m"
}

# Check if we are in the correct namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$CURRENT_NS" != "lb-demo" ]; then
  info "Switching to lb-demo namespace"
  kubectl config set-context --current --namespace=lb-demo
  echo ""
fi

headline "Kubernetes Load Balancing Workshop - Testing"
echo ""

# Check pods status
section "Checking Pod Status"
kubectl get pods
echo ""

# Check services
section "Checking Services"
kubectl get services
echo ""

# Check ingresses
section "Checking Ingresses"
kubectl get ingress
echo ""

# Basic Load Balancing Test
headline "Testing Basic Load Balancing"
section "Starting port-forward for web-service-all (keep this terminal open)"
echo "kubectl port-forward svc/web-service-all 8080:80"
echo ""

section "In a new terminal, run the following to test load balancing:"
echo "for i in {1..10}; do curl -s http://localhost:8080 | grep \"Pod:\"; done"
echo ""

section "Or run this automated test to see pod distribution clearly:"
echo "for i in {1..20}; do"
echo "  echo \"Request \$i: \$(curl -s http://localhost:8080 | grep \"Pod:\" | tr -d '\n')\""
echo "  sleep 0.5"
echo "done"
echo ""

# Version-specific service test
headline "Testing Version-specific Services"
section "For version 1 (in a new terminal):"
echo "kubectl port-forward svc/web-service-v1 8081:80"
echo "curl http://localhost:8081"
echo ""

section "For version 2 (in a new terminal):"
echo "kubectl port-forward svc/web-service-v2 8082:80"
echo "curl http://localhost:8082"
echo ""

# Session Affinity Test
headline "Testing Session Affinity"
section "Start port-forward for sticky session service:"
echo "kubectl port-forward svc/web-service-sticky 8083:80"
echo ""

section "Test sticky sessions with multiple requests (should go to the same pod):"
echo "for i in {1..5}; do curl -s http://localhost:8083 | grep \"Pod:\"; done"
echo ""

section "Visualize sticky session with multiple requests (should show the same pod):"
echo "for i in {1..10}; do"
echo "  echo \"Request \$i: \$(curl -s http://localhost:8083 | grep \"Pod:\" | tr -d '\n')\""
echo "  sleep 0.5"
echo "done"
echo ""

# Ingress Testing
headline "Testing Ingress Routing"

# Additional information about Ingress controller status
section "Check Ingress Controller Status"
warning "⚠️ Note: If you're getting 404 errors, ensure the Ingress controller is running properly."
echo "Run the following command to check the Ingress controller pods (might be in a different namespace):"
echo "kubectl get pods -n ingress-nginx"
echo ""

section "For proper Ingress testing, you need to port-forward the Ingress Controller:"
echo "kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8084:80"
echo ""

section "If you're using a different Ingress setup (e.g. Docker Desktop, minikube, etc), use the appropriate command:"
echo "- For minikube: minikube service ingress-nginx-controller -n ingress-nginx"
echo "- For Docker Desktop: kubectl port-forward -n kube-system svc/nginx-ingress-controller 8084:80"
echo ""

section "To test Ingress routing (requires hosts file modification):"
echo "Add the following to your /etc/hosts file:"
echo "127.0.0.1    lb.k8s.local"
echo ""

section "For basic ingress (use the port you forwarded to, e.g. 8084):"
echo "curl -H \"Host: lb.k8s.local\" http://localhost:8084/  # Will load balance between v1 and v2"
echo ""

section "For automated testing of ingress load balancing:"
echo "for i in {1..20}; do"
echo "  echo \"Request \$i: \$(curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Pod:\" | tr -d '\n')\""
echo "  sleep 0.5"
echo "done"
echo ""

section "For path-based routing:"
echo "curl -H \"Host: lb.k8s.local\" http://localhost:8084/v1/  # Should go to v1 only"
echo "curl -H \"Host: lb.k8s.local\" http://localhost:8084/v2/  # Should go to v2 only"
echo ""

# Canary Deployment Visualization
headline "Canary Deployment Visualization"
section "To visualize canary deployment (traffic split between v1 and v2):"
echo "for i in {1..100}; do curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Version\"; done | sort | uniq -c"
echo ""

section "For a more visual canary testing experience:"
echo "for i in {1..50}; do"
echo "  version=\$(curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Version\" | tr -d '\n')"
echo "  pod=\$(curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Pod:\" | tr -d '\n')"
echo "  if [[ \"\$version\" == *\"Version 1\"* ]]; then"
echo "    echo -e \"Request \$i: \033[0;36m\$version\033[0m - \$pod\""
echo "  else"
echo "    echo -e \"Request \$i: \033[0;32m\$version\033[0m - \$pod\""
echo "  fi"
echo "  sleep 0.5"
echo "done"
echo ""

section "For cookie-based canary testing (if enabled in ingress-canary.yaml):"
echo "# To get v1 (main version):"
echo "curl -s -H \"Host: lb.k8s.local\" --cookie \"canary-cookie=never\" http://localhost:8084/ | grep \"Version\""
echo "# To get v2 (canary version):" 
echo "curl -s -H \"Host: lb.k8s.local\" --cookie \"canary-cookie=always\" http://localhost:8084/ | grep \"Version\""
echo ""

headline "Testing Complete"
info "Run these commands to observe load balancing behavior in real-time"
echo ""
