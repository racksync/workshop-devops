#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}====== Deploying ConfigMap and Secret Demo ======${NC}"

# Create namespace
echo -e "${YELLOW}Creating namespace...${NC}"
kubectl create namespace config-demo

# Set current context to use this namespace
echo -e "${YELLOW}Setting namespace context...${NC}"
kubectl config set-context --current --namespace=config-demo

# Create ConfigMaps
echo -e "${YELLOW}Creating ConfigMaps...${NC}"
kubectl apply -f simple-configmap.yaml
echo "Creating JSON ConfigMap from file..."
echo '{
  "apiEndpoint": "https://api.example.com",
  "enableFeatureA": true,
  "maxConnections": 100
}' > config.json
kubectl create configmap json-config --from-file=config.json
kubectl apply -f feature-flags.yaml

# Create Secrets
echo -e "${YELLOW}Creating Secrets...${NC}"
kubectl apply -f app-secret.yaml
kubectl create secret generic api-keys \
  --from-literal=api-key=2f5a14d7e9c83b4 \
  --from-literal=api-secret=c87d4pq39fjwlc2890f

# Create test resources
echo -e "${YELLOW}Creating demo pod...${NC}"
kubectl apply -f app-pod.yaml

# Create real-world example
echo -e "${YELLOW}Creating real-world example...${NC}"
kubectl apply -f real-world-example.yaml

# Wait for resources to be ready
echo -e "${YELLOW}Waiting for resources to be ready...${NC}"
sleep 5

# Show created resources
echo -e "${GREEN}====== Resources Created ======${NC}"
echo -e "${YELLOW}ConfigMaps:${NC}"
kubectl get configmaps
echo -e "${YELLOW}Secrets:${NC}"
kubectl get secrets
echo -e "${YELLOW}Pods:${NC}"
kubectl get pods

echo -e "${GREEN}====== ConfigMap and Secret Demo Deployed Successfully ======${NC}"
echo -e "${YELLOW}To view demo output, run:${NC}"
echo "kubectl logs config-demo-pod"
echo -e "${YELLOW}To test ConfigMap updates, run:${NC}"
echo "kubectl apply -f update-configmap.yaml"
echo -e "${YELLOW}To cleanup all resources, run:${NC}"
echo "./cleanup.sh"
