#!/bin/bash

# Define color functions
function print_headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function print_info() {
  echo -e "\033[0;34m$1\033[0m"
}

function print_success() {
  echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
  echo -e "\033[0;31m$1\033[0m"
}

function print_test_result() {
  if [ "$2" == "SUCCESS" ]; then
    echo -e "| $1 | \033[0;32mSUCCESS\033[0m |"
  elif [ "$2" == "FAILED" ]; then
    echo -e "| $1 | \033[0;31mFAILED\033[0m |"
  elif [ "$2" == "EXPECTED FAIL" ]; then
    echo -e "| $1 | \033[0;33mEXPECTED FAIL\033[0m |"
  fi
}

# Introduction
print_headline "Network Policies Workshop - Testing Script"
print_info "This script will test the connectivity between pods with applied network policies."
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
  print_error "kubectl command not found. Please install kubectl first."
  exit 1
fi

# Check if we're in the right namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$CURRENT_NS" != "netpol-demo" ]; then
  print_info "Currently not in netpol-demo namespace, switching context"
  kubectl config set-context --current --namespace=netpol-demo
  echo ""
fi

# Check if pods are ready
print_info "Checking if all pods are running"
PODS_READY=$(kubectl get pods -o jsonpath='{.items[?(@.status.phase!="Running")].metadata.name}')
if [ -n "$PODS_READY" ]; then
  print_error "Not all pods are running. Check pod status with 'kubectl get pods'"
  kubectl get pods
  exit 1
else
  print_success "All pods are running"
fi
echo ""

# Get pod names
FRONTEND_POD=$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')
BACKEND_POD=$(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}')
TEST_POD=$(kubectl get pod -l role=test -o jsonpath='{.items[0].metadata.name}')

print_headline "Running Network Connectivity Tests"
echo ""

print_info "Test Results Table:"
echo "| Test | Result |"
echo "|------|--------|"

# Test 1: Test pod to frontend (should fail)
TEST1_RESULT=$(kubectl exec -it $TEST_POD -- curl -s --connect-timeout 5 frontend-svc 2>&1)
if [[ $TEST1_RESULT == *"Connection timed out"* ]] || [[ $TEST1_RESULT == *"command terminated with exit code"* ]]; then
  print_test_result "Test pod to frontend" "EXPECTED FAIL"
else
  print_test_result "Test pod to frontend" "FAILED"
fi

# Test 2: Test pod to backend (should fail)
TEST2_RESULT=$(kubectl exec -it $TEST_POD -- curl -s --connect-timeout 5 backend-svc:8080 2>&1)
if [[ $TEST2_RESULT == *"Connection timed out"* ]] || [[ $TEST2_RESULT == *"command terminated with exit code"* ]]; then
  print_test_result "Test pod to backend" "EXPECTED FAIL"
else
  print_test_result "Test pod to backend" "FAILED"
fi

# Test 3: Test pod to database (should fail)
TEST3_RESULT=$(kubectl exec -it $TEST_POD -- nc -zvw 1 database-svc 3306 2>&1)
if [[ $TEST3_RESULT == *"Connection timed out"* ]] || [[ $TEST3_RESULT == *"command terminated with exit code"* ]]; then
  print_test_result "Test pod to database" "EXPECTED FAIL"
else
  print_test_result "Test pod to database" "FAILED"
fi

# Test 4: Frontend to backend (should succeed)
TEST4_RESULT=$(kubectl exec -it $FRONTEND_POD -- curl -s --connect-timeout 5 backend-svc:8080 2>&1)
if [[ $TEST4_RESULT == *"Backend API running on port 8080"* ]]; then
  print_test_result "Frontend to backend" "SUCCESS"
else
  print_test_result "Frontend to backend" "FAILED"
fi

# Test 5: Backend to database (port check, should succeed)
TEST5_RESULT=$(kubectl exec -it $BACKEND_POD -- nc -zvw 1 database-svc 3306 2>&1)
if [[ $TEST5_RESULT == *"open"* ]] || [[ $TEST5_RESULT == *"succeeded"* ]]; then
  print_test_result "Backend to database" "SUCCESS"
else
  print_test_result "Backend to database" "FAILED"
fi

echo ""
print_headline "DNS Test"

# Test 6: Test pod DNS resolution (should succeed if DNS policy is applied)
TEST6_RESULT=$(kubectl exec -it $TEST_POD -- nslookup kubernetes.default 2>&1)
if [[ $TEST6_RESULT == *"Address"* ]]; then
  print_test_result "DNS resolution from test pod" "SUCCESS"
else
  print_test_result "DNS resolution from test pod" "FAILED"
fi

echo ""
print_headline "Network Policy Verification"
echo ""
print_info "Currently applied Network Policies:"
kubectl get networkpolicies
echo ""

# Summary
print_headline "Testing Complete!"
print_info "This test verifies that the network policies are correctly applied."
print_info "Expected results:"
print_info "- Test pod cannot connect to frontend, backend, or database (isolation)"
print_info "- Frontend can connect to backend (allowed by policy)"
print_info "- Backend can connect to database (allowed by policy)"
print_info "- All pods can resolve DNS (allowed by DNS policy)"
echo ""
print_info "For external access, make sure demo.k8s.local is in your /etc/hosts file:"
print_info "127.0.0.1 demo.k8s.local"
echo ""
