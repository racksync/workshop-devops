#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}====== Cleaning up ConfigMap and Secret Demo ======${NC}"

# Check if namespace exists
if kubectl get namespace config-demo > /dev/null 2>&1; then
    # Delete all resources created for the demo
    echo -e "${YELLOW}Deleting all resources in config-demo namespace...${NC}"
    
    # Delete test pod
    echo -e "${YELLOW}Deleting test pod...${NC}"
    kubectl delete -f app-pod.yaml --ignore-not-found=true
    
    # Delete real-world examples
    echo -e "${YELLOW}Deleting real-world example resources...${NC}"
    kubectl delete -f real-world-example.yaml --ignore-not-found=true
    
    # Delete ConfigMaps
    echo -e "${YELLOW}Deleting ConfigMaps...${NC}"
    kubectl delete -f simple-configmap.yaml --ignore-not-found=true
    kubectl delete -f update-configmap.yaml --ignore-not-found=true
    kubectl delete -f feature-flags.yaml --ignore-not-found=true
    kubectl delete configmap json-config --ignore-not-found=true
    
    # Delete Secrets
    echo -e "${YELLOW}Deleting Secrets...${NC}"
    kubectl delete -f app-secret.yaml --ignore-not-found=true
    kubectl delete secret api-keys --ignore-not-found=true
    
    # Delete generated config file
    echo -e "${YELLOW}Deleting generated config file...${NC}"
    rm -f config.json

    # Check if any resources are still present
    echo -e "${YELLOW}Checking for any remaining resources...${NC}"
    kubectl get all
    
    # Delete namespace
    echo -e "${YELLOW}Deleting namespace...${NC}"
    kubectl delete namespace config-demo
    
    # Reset context to default namespace
    echo -e "${YELLOW}Resetting namespace context...${NC}"
    kubectl config set-context --current --namespace=default
    
    echo -e "${GREEN}====== Cleanup Completed ======${NC}"
else
    echo -e "${YELLOW}Namespace config-demo does not exist. Nothing to clean up.${NC}"
fi
