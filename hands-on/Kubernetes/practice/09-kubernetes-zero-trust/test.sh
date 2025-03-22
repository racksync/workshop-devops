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

function print_test() {
  echo -e "\e[0;36m$1\e[0m"
}

print_headline "Zero-Trust Security Architecture Testing"
print_headline "========================================="
echo ""

# Check if namespace exists
print_test "Checking if zero-trust-demo namespace exists"
if kubectl get namespace zero-trust-demo > /dev/null 2>&1; then
  print_success "✓ Namespace zero-trust-demo exists"
  kubectl config set-context --current --namespace=zero-trust-demo
else
  print_error "✗ Namespace zero-trust-demo not found. Please run deploy.sh first!"
  exit 1
fi
echo ""

# Check Istio and mTLS enforcement
print_test "Testing mTLS enforcement"
print_info "Checking if mTLS is enforced between services"
mtls_status=$(kubectl exec deploy/frontend -- curl -s http://backend:8080/status)
if echo "$mtls_status" | grep -q "tls"; then
  print_success "✓ mTLS is properly enforced between services"
else
  print_error "✗ mTLS is not properly enforced"
fi
echo ""

# Test network policies
print_test "Testing Network Policies"
print_info "Attempting unauthorized network connection (should fail)"
kubectl run test-pod --image=busybox --restart=Never -- wget -T 5 backend:8080
sleep 5
pod_status=$(kubectl get pod test-pod -o jsonpath='{.status.phase}')
kubectl delete pod test-pod --force --grace-period=0
if [ "$pod_status" == "Failed" ]; then
  print_success "✓ Network Policies are correctly blocking unauthorized access"
else
  print_error "✗ Network Policies are not correctly blocking access"
fi
echo ""

# Test OPA Gatekeeper policies
print_test "Testing OPA Gatekeeper Policies"
print_info "Attempting to create a pod without security context (should be denied)"
kubectl apply -f test-no-securitycontext.yaml > /dev/null 2>&1
sleep 2
if kubectl get pod insecure-pod > /dev/null 2>&1; then
  print_error "✗ OPA Gatekeeper did not block pod without security context"
  kubectl delete pod insecure-pod --force --grace-period=0
else
  print_success "✓ OPA Gatekeeper correctly blocked pod without security context"
fi
echo ""

# Test Vault secret management
print_test "Testing HashiCorp Vault Integration"
print_info "Checking if secure app can access secrets from Vault"
vault_test=$(kubectl exec deploy/frontend -- curl -s http://backend:8080/secret)
if echo "$vault_test" | grep -q "Vault secret"; then
  print_success "✓ Application can securely access Vault secrets"
else
  print_error "✗ Application cannot access Vault secrets"
fi
echo ""

# Test Falco detection
print_test "Testing Falco Runtime Detection"
print_info "Simulating suspicious activity (file manipulation in container)"
kubectl exec deploy/frontend -- touch /etc/shadow 2>/dev/null
sleep 5
# Check if Falco detected this event
if kubectl logs -l app=falco --tail=50 | grep -q "File below / detected"; then
  print_success "✓ Falco detected suspicious file manipulation"
else
  print_error "✗ Falco did not detect suspicious activity"
fi
echo ""

# Test service-to-service communication
print_test "Testing Secure Service-to-Service Communication"
print_info "Checking if frontend can securely communicate with backend"
com_test=$(kubectl exec deploy/frontend -- curl -s http://backend:8080/api)
if echo "$com_test" | grep -q "success"; then
  print_success "✓ Services can communicate securely"
else
  print_error "✗ Service communication is not working correctly"
fi
echo ""

print_headline "Testing Complete!"
print_info "Run ./run-security-tests.sh for more detailed security testing scenarios"
print_warning "Note: Make sure demo.k8s.local is in your /etc/hosts file pointing to 127.0.0.1"
echo ""

exit 0
