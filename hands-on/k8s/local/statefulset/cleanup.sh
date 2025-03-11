#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== StatefulSet Workshop Cleanup =====${NC}"

# Make sure we're in the correct namespace
echo -e "${GREEN}Setting context to statefulset-demo namespace...${NC}"
kubectl config set-context --current --namespace=statefulset-demo
echo

# Remove resources in reverse order of creation
# Start with ingress
echo -e "${GREEN}Removing Ingress...${NC}"
kubectl delete -f ingress.yaml --ignore-not-found
echo

# Remove MongoDB Admin UI
echo -e "${GREEN}Removing MongoDB Admin UI...${NC}"
kubectl delete -f mongodb-admin-service.yaml --ignore-not-found
echo

# Remove MongoDB Replica Set
echo -e "${GREEN}Removing MongoDB Cluster StatefulSet...${NC}"
kubectl delete -f statefulset-mongodb-cluster.yaml --ignore-not-found
echo

# Remove MongoDB Cluster Headless Service
echo -e "${GREEN}Removing MongoDB Cluster Headless Service...${NC}"
kubectl delete -f mongodb-cluster-headless-service.yaml --ignore-not-found
echo

# Remove MongoDB StatefulSet
echo -e "${GREEN}Removing MongoDB StatefulSet...${NC}"
kubectl delete -f statefulset.yaml --ignore-not-found
echo

# Remove services
echo -e "${GREEN}Removing MongoDB Services...${NC}"
kubectl delete -f service.yaml --ignore-not-found
kubectl delete -f headless-service.yaml --ignore-not-found
echo

# Display remaining resources
echo -e "${YELLOW}Checking for any remaining PersistentVolumeClaims...${NC}"
kubectl get pvc
echo

# Notice about PVCs
echo -e "${YELLOW}Note: PVCs created by StatefulSets are not automatically deleted.${NC}"
echo -e "${YELLOW}If you want to delete them manually, run:${NC}"
echo -e "  kubectl delete pvc --all -n statefulset-demo"
echo

# Ask user if they want to delete PVCs
read -p "Do you want to delete all PVCs now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${RED}Deleting all PersistentVolumeClaims...${NC}"
    kubectl delete pvc --all
    echo -e "${GREEN}All PVCs deleted.${NC}"
else
    echo -e "${GREEN}PVCs preserved. You can delete them manually later if needed.${NC}"
fi
echo

# Finally, remove namespace
echo -e "${RED}Removing statefulset-demo namespace...${NC}"
kubectl delete -f namespace.yaml --ignore-not-found
echo

# Reset namespace
echo -e "${GREEN}Resetting context to default namespace...${NC}"
kubectl config set-context --current --namespace=default
echo

echo -e "${BLUE}===== Cleanup Complete =====${NC}"
