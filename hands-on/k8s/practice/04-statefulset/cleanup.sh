#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored text
print_colored() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

print_colored "$BLUE" "===== StatefulSet Workshop Cleanup ====="
echo ""

# Make sure we're in the correct namespace
print_colored "$YELLOW" "Setting context to statefulset-demo namespace..."
echo ""
kubectl config set-context --current --namespace=statefulset-demo
echo ""

# Remove resources in reverse order of creation
# Start with ingress
print_colored "$YELLOW" "Removing Ingress..."
echo ""
kubectl delete -f ingress.yaml --ignore-not-found
echo ""

# Remove MongoDB Admin UI
print_colored "$YELLOW" "Removing MongoDB Admin UI..."
echo ""
kubectl delete -f mongodb-admin-service.yaml --ignore-not-found
echo ""

# Remove MongoDB Replica Set
print_colored "$YELLOW" "Removing MongoDB Cluster StatefulSet..."
echo ""
kubectl delete -f statefulset-mongodb-cluster.yaml --ignore-not-found
echo ""

# Remove MongoDB Cluster Headless Service
print_colored "$YELLOW" "Removing MongoDB Cluster Headless Service..."
echo ""
kubectl delete -f mongodb-cluster-headless-service.yaml --ignore-not-found
echo ""

# Remove MongoDB StatefulSet
print_colored "$YELLOW" "Removing MongoDB StatefulSet..."
echo ""
kubectl delete -f statefulset.yaml --ignore-not-found
echo ""

# Remove services
print_colored "$YELLOW" "Removing MongoDB Services..."
echo ""
kubectl delete -f service.yaml --ignore-not-found
kubectl delete -f headless-service.yaml --ignore-not-found
echo ""

# Display remaining resources
print_colored "$YELLOW" "Checking for any remaining PersistentVolumeClaims..."
echo ""
kubectl get pvc
echo ""

# Notice about PVCs
print_colored "$YELLOW" "Note: PVCs created by StatefulSets are not automatically deleted."
print_colored "$YELLOW" "If you want to delete them manually, run:"
print_colored "$YELLOW" "  kubectl delete pvc --all -n statefulset-demo"
echo ""

# Ask user if they want to delete PVCs now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    print_colored "$YELLOW" "Deleting all PersistentVolumeClaims..."
    echo ""
    kubectl delete pvc --all
    print_colored "$GREEN" "All PVCs deleted."
else
    print_colored "$YELLOW" "PVCs preserved. You can delete them manually later if needed."
fi
echo ""

# Finally, remove namespace
print_colored "$YELLOW" "Removing statefulset-demo namespace..."
echo ""
kubectl delete -f namespace.yaml --ignore-not-found
echo ""

# Reset namespace
print_colored "$YELLOW" "Resetting context to default namespace..."
echo ""
kubectl config set-context --current --namespace=default
echo ""

print_colored "$BLUE" "===== Cleanup Complete ====="
