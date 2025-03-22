#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for displaying status messages
print_status() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

# Function for displaying success messages
print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function for displaying error messages
print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_success "====== Testing ConfigMap and Secret Demo ======"

# Check if namespace exists
if ! kubectl get namespace config-demo > /dev/null 2>&1; then
    print_error "Namespace config-demo not found. Please run deploy.sh first."
    exit 1
fi

# Set context to use the demo namespace
kubectl config set-context --current --namespace=config-demo

# Test 1: Verify ConfigMaps exist
print_status "Test 1: Verifying ConfigMaps..."
if kubectl get configmap app-config > /dev/null 2>&1; then
    print_success "✓ ConfigMap app-config exists"
    kubectl describe configmap app-config
else
    print_error "✗ ConfigMap app-config not found"
fi

if kubectl get configmap json-config > /dev/null 2>&1; then
    print_success "✓ ConfigMap json-config exists"
else
    print_error "✗ ConfigMap json-config not found"
fi

if kubectl get configmap feature-flags > /dev/null 2>&1; then
    print_success "✓ ConfigMap feature-flags exists"
else
    print_error "✗ ConfigMap feature-flags not found"
fi

# Test 2: Verify Secrets exist
print_status "Test 2: Verifying Secrets..."
if kubectl get secret app-secret > /dev/null 2>&1; then
    print_success "✓ Secret app-secret exists"
else
    print_error "✗ Secret app-secret not found"
fi

if kubectl get secret api-keys > /dev/null 2>&1; then
    print_success "✓ Secret api-keys exists"
else
    print_error "✗ Secret api-keys not found"
fi

# Test 3: Check if demo pod is running
print_status "Test 3: Checking demo pod..."
if kubectl get pod config-demo-pod > /dev/null 2>&1; then
    POD_STATUS=$(kubectl get pod config-demo-pod -o jsonpath='{.status.phase}')
    if [ "$POD_STATUS" == "Running" ]; then
        print_success "✓ Pod config-demo-pod is running"
        print_status "Pod logs:"
        kubectl logs config-demo-pod --tail=5
    else
        print_error "✗ Pod config-demo-pod is not running (status: $POD_STATUS)"
        kubectl describe pod config-demo-pod
    fi
else
    print_error "✗ Pod config-demo-pod not found"
fi

# Test 4: Test ConfigMap update
print_status "Test 4: Testing ConfigMap update..."
echo "Applying updated ConfigMap..."
kubectl apply -f update-configmap.yaml

print_status "Waiting for propagation (60 seconds)..."
sleep 10
print_status "Pod logs after 10 seconds:"
kubectl logs config-demo-pod --tail=3

print_status "Environment variables from ConfigMap will not update automatically."
print_status "But files mounted as volumes should update in about 60 seconds."

print_status "To verify volume updates, run:"
echo "kubectl exec -it config-demo-pod -- cat /etc/config/app.properties"

# Test 5: Verify real-world example deployment
print_status "Test 5: Verifying real-world example deployment..."
if kubectl get deployment web-application > /dev/null 2>&1; then
    DEPLOYMENT_STATUS=$(kubectl get deployment web-application -o jsonpath='{.status.readyReplicas}')
    if [ "$DEPLOYMENT_STATUS" -gt 0 ]; then
        print_success "✓ Deployment web-application is ready"
    else
        print_error "✗ Deployment web-application is not ready"
        kubectl describe deployment web-application
    fi
else
    print_error "✗ Deployment web-application not found"
fi

print_success "====== Testing Complete ======"
print_status "To clean up all resources, run:"
echo "./cleanup.sh"
