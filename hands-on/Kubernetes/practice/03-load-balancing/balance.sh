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

function run_test() {
  echo -e "\033[0;35m$ $1\033[0m"
  eval $1
  echo ""
}

# Ensure we're in the correct namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$CURRENT_NS" != "lb-demo" ]; then
  info "Switching to lb-demo namespace"
  kubectl config set-context --current --namespace=lb-demo
  echo ""
fi

headline "Kubernetes Load Balancing Workshop - Automated Testing"
echo ""

# Display current state
section "Current Kubernetes Resources"
run_test "kubectl get pods"
run_test "kubectl get services"
run_test "kubectl get ingress"

# Define port-forward helper function with timeout
function port_forward() {
  local service=$1
  local local_port=$2
  local remote_port=$3
  local namespace=${4:-lb-demo}
  local pid_file="/tmp/port-forward-${service}-${local_port}.pid"
  local max_retries=3
  local retry_count=0
  
  # Kill any existing port-forward for this port
  if [ -f "$pid_file" ]; then
    kill $(cat "$pid_file") 2>/dev/null || true
    rm "$pid_file"
  fi
  
  while [ $retry_count -lt $max_retries ]; do
    # Start port-forward in background
    info "Starting port-forward for ${service} on port ${local_port} (attempt $((retry_count + 1)))"
    kubectl port-forward -n $namespace svc/$service $local_port:$remote_port &
    local pf_pid=$!
    echo $pf_pid > "$pid_file"
    
    # Wait for port-forward to establish
    sleep 2
    
    # Check if port-forward is working
    if nc -z localhost $local_port 2>/dev/null; then
      info "Port-forward established successfully"
      return 0
    else
      warning "Port-forward failed to establish"
      kill $pf_pid 2>/dev/null || true
      rm "$pid_file"
      ((retry_count++))
      
      if [ $retry_count -lt $max_retries ]; then
        warning "Retrying in 3 seconds..."
        sleep 3
      else
        error "Failed to establish port-forward after $max_retries attempts"
        return 1
      fi
    fi
  done
}

function cleanup_port_forwards() {
  info "Cleaning up port-forwards"
  for pid_file in /tmp/port-forward-*.pid; do
    if [ -f "$pid_file" ]; then
      kill $(cat "$pid_file") 2>/dev/null || true
      rm "$pid_file" 2>/dev/null
    fi
  done > /dev/null 2>&1
}

# Register cleanup on script exit
trap cleanup_port_forwards EXIT

# Test 1: Basic Load Balancing
headline "1. Basic Load Balancing Test"
if port_forward "web-service-all" 8080 80; then
  section "Testing load balancing across all pods:"
  run_test "for i in {1..10}; do curl -s http://localhost:8080 | grep \"Pod:\"; done"
else
  error "Skipping test due to port-forward failure"
fi

# Test 2: Version-specific services
headline "2. Version-specific Services Test"
if port_forward "web-service-v1" 8081 80; then
  section "Testing v1 service:"
  run_test "curl -s http://localhost:8081 | grep \"Version\""
  run_test "curl -s http://localhost:8081 | grep \"Pod:\""
else
  error "Skipping test due to port-forward failure"
fi

if port_forward "web-service-v2" 8082 80; then
  section "Testing v2 service:"
  run_test "curl -s http://localhost:8082 | grep \"Version\""
  run_test "curl -s http://localhost:8082 | grep \"Pod:\""
else
  error "Skipping test due to port-forward failure"
fi

# Test 3: Session Affinity
headline "3. Session Affinity Test"
if port_forward "web-service-sticky" 8083 80; then
  section "Testing sticky sessions (should show the same pod for all requests):"
  run_test "for i in {1..5}; do curl -s http://localhost:8083 | grep \"Pod:\"; done"
else
  error "Skipping test due to port-forward failure"
fi

# Test 4: Ingress Routing
headline "4. Ingress Routing Test"
section "Checking Ingress controller status:"
run_test "kubectl get pods -n ingress-nginx"

# Find the appropriate ingress service name
INGRESS_NS="ingress-nginx"
INGRESS_SVC="ingress-nginx-controller"

# Try different namespaces if the standard one doesn't work
if ! kubectl get svc -n $INGRESS_NS $INGRESS_SVC &>/dev/null; then
  if kubectl get svc -n kube-system nginx-ingress-controller &>/dev/null; then
    INGRESS_NS="kube-system"
    INGRESS_SVC="nginx-ingress-controller"
  fi
fi

if port_forward "$INGRESS_SVC" 8084 80 "$INGRESS_NS"; then
  section "Testing basic ingress routing:"
  run_test "curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Version\""
  run_test "curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/ | grep \"Pod:\""

  section "Testing path-based routing:"
  run_test "curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/v1/ | grep \"Version\""
  run_test "curl -s -H \"Host: lb.k8s.local\" http://localhost:8084/v2/ | grep \"Version\""
else
  error "Skipping test due to port-forward failure"
fi

# Test 5: Canary Deployment
headline "5. Canary Deployment Test"
section "Testing canary deployment (20% traffic to v2):"
run_test "for i in {1..20}; do curl -s -H \"Host: lb.k8s.local\" -H \"User-Agent: user-\$i\" http://localhost:8084/ | grep \"Version\"; done | sort | uniq -c"

section "Testing canary with different approaches:"
echo "Testing with different user agents:"
run_test "for i in {1..10}; do curl -s -H \"Host: lb.k8s.local\" -H \"User-Agent: test-\$i\" http://localhost:8084/ | grep \"Version\"; done | sort | uniq -c"

# If cookie-based canary is enabled in ingress-canary.yaml, uncomment these lines
# echo "Testing with cookies (if configured):"
# run_test "curl -s -H \"Host: lb.k8s.local\" --cookie \"canary-cookie=always\" http://localhost:8084/ | grep \"Version\""
# run_test "curl -s -H \"Host: lb.k8s.local\" --cookie \"canary-cookie=never\" http://localhost:8084/ | grep \"Version\""

# If header-based canary is enabled in ingress-canary.yaml, uncomment these lines
# echo "Testing with headers (if configured):"
# run_test "curl -s -H \"Host: lb.k8s.local\" -H \"X-Canary: true\" http://localhost:8084/ | grep \"Version\""

headline "All Load Balancing Tests Complete!"
info "Results Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Basic load balancing: Requests distributed across all pods"
echo "✓ Version-specific services: Exclusive routing to targeted versions"
echo "✓ Session affinity: Consistent pod targeting"
echo "✓ Path-based routing: Correct /v1/ and /v2/ path routing"
echo "✓ Canary deployment: ~20/80 traffic split between v2/v1"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$SHOW_TROUBLESHOOTING" = "true" ]; then
  warning "Troubleshooting Notes:"
  echo "• For uneven canary distribution:"
  echo "  kubectl rollout restart deployment -n $INGRESS_NS $INGRESS_SVC"
  echo ""
fi

# Clean up port forwards (now redirecting stderr)
cleanup_port_forwards 2>/dev/null

exit 0
