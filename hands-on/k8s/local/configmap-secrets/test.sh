#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}====== Testing ConfigMap and Secret Demo ======${NC}"

# Check if namespace exists
if ! kubectl get namespace config-demo > /dev/null 2>&1; then
    echo -e "${RED}Namespace config-demo not found. Please run deploy.sh first.${NC}"
    exit 1
fi

# Set context to use the demo namespace
kubectl config set-context --current --namespace=config-demo

# Test 1: Verify ConfigMaps exist
echo -e "${YELLOW}Test 1: Verifying ConfigMaps...${NC}"
if kubectl get configmap app-config > /dev/null 2>&1; then
    echo -e "${GREEN}✓ ConfigMap app-config exists${NC}"
    kubectl describe configmap app-config
else
    echo -e "${RED}✗ ConfigMap app-config not found${NC}"
fi

if kubectl get configmap json-config > /dev/null 2>&1; then
    echo -e "${GREEN}✓ ConfigMap json-config exists${NC}"
else
    echo -e "${RED}✗ ConfigMap json-config not found${NC}"
fi

if kubectl get configmap feature-flags > /dev/null 2>&1; then
    echo -e "${GREEN}✓ ConfigMap feature-flags exists${NC}"
else
    echo -e "${RED}✗ ConfigMap feature-flags not found${NC}"
fi

# Test 2: Verify Secrets exist
echo -e "${YELLOW}Test 2: Verifying Secrets...${NC}"
if kubectl get secret app-secret > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Secret app-secret exists${NC}"
else
    echo -e "${RED}✗ Secret app-secret not found${NC}"
fi

if kubectl get secret api-keys > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Secret api-keys exists${NC}"
else
    echo -e "${RED}✗ Secret api-keys not found${NC}"
fi

# Test 3: Check if demo pod is running
echo -e "${YELLOW}Test 3: Checking demo pod...${NC}"
if kubectl get pod config-demo-pod > /dev/null 2>&1; then
    POD_STATUS=$(kubectl get pod config-demo-pod -o jsonpath='{.status.phase}')
    if [ "$POD_STATUS" == "Running" ]; then
        echo -e "${GREEN}✓ Pod config-demo-pod is running${NC}"
        echo -e "${YELLOW}Pod logs:${NC}"
        kubectl logs config-demo-pod --tail=5
    else
        echo -e "${RED}✗ Pod config-demo-pod is not running (status: $POD_STATUS)${NC}"
        kubectl describe pod config-demo-pod
    fi
else
    echo -e "${RED}✗ Pod config-demo-pod not found${NC}"
fi

# Test 4: Test ConfigMap update
echo -e "${YELLOW}Test 4: Testing ConfigMap update...${NC}"
echo "Applying updated ConfigMap..."
kubectl apply -f update-configmap.yaml

echo "Waiting for propagation (60 seconds)..."
sleep 10
echo "Pod logs after 10 seconds:"
kubectl logs config-demo-pod --tail=3

echo "Environment variables from ConfigMap will not update automatically."
echo "But files mounted as volumes should update in about 60 seconds."

echo -e "${YELLOW}To verify volume updates, run:${NC}"
echo "kubectl exec -it config-demo-pod -- cat /etc/config/app.properties"

# Test 5: Verify real-world example deployment
echo -e "${YELLOW}Test 5: Verifying real-world example deployment...${NC}"
if kubectl get deployment web-application > /dev/null 2>&1; then
    DEPLOYMENT_STATUS=$(kubectl get deployment web-application -o jsonpath='{.status.readyReplicas}')
    if [ "$DEPLOYMENT_STATUS" -gt 0 ]; then
        echo -e "${GREEN}✓ Deployment web-application is ready${NC}"
    else
        echo -e "${RED}✗ Deployment web-application is not ready${NC}"
        kubectl describe deployment web-application
    fi
else
    echo -e "${RED}✗ Deployment web-application not found${NC}"
fi

echo -e "${GREEN}====== Testing Complete ======${NC}"
echo -e "${YELLOW}To clean up all resources, run:${NC}"
echo "./cleanup.sh"
