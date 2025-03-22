#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored text
print_colored() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

print_colored "$BLUE" "===== StatefulSet Workshop Deployment ====="
echo ""

# Create namespace
print_colored "$YELLOW" "Creating namespace..."
echo ""
kubectl apply -f namespace.yaml
echo ""

# Set context to our namespace
print_colored "$YELLOW" "Setting context to statefulset-demo namespace..."
echo ""
kubectl config set-context --current --namespace=statefulset-demo
echo ""

# Create headless service first (required for StatefulSet)
print_colored "$YELLOW" "Creating headless service for MongoDB..."
echo ""
kubectl apply -f headless-service.yaml
echo ""

# Create regular service
print_colored "$YELLOW" "Creating regular ClusterIP service for MongoDB..."
echo ""
kubectl apply -f service.yaml
echo ""

# Create StatefulSet
print_colored "$YELLOW" "Creating StatefulSet for MongoDB..."
echo ""
kubectl apply -f statefulset.yaml
echo ""

# Wait for StatefulSet to be ready
print_colored "$YELLOW" "Waiting for MongoDB StatefulSet to be ready..."
echo ""
kubectl rollout status statefulset/mongodb --timeout=180s
echo ""

# MongoDB Admin UI
print_colored "$YELLOW" "Deploying MongoDB Admin UI (Mongo Express)..."
echo ""
kubectl apply -f mongodb-admin-service.yaml
echo ""

# Ingress (if needed)
print_colored "$YELLOW" "Creating Ingress for MongoDB Admin UI..."
echo ""
kubectl apply -f ingress.yaml
echo ""

# MongoDB Replica Set components
print_colored "$YELLOW" "Creating headless service for MongoDB Cluster..."
echo ""
kubectl apply -f mongodb-cluster-headless-service.yaml
echo ""

print_colored "$YELLOW" "Creating StatefulSet for MongoDB Replica Set..."
echo ""
kubectl apply -f statefulset-mongodb-cluster.yaml
echo ""

# Wait for the MongoDB Cluster StatefulSet to be ready
print_colored "$YELLOW" "Waiting for MongoDB Cluster StatefulSet to be ready..."
echo ""
kubectl rollout status statefulset/mongodb-cluster --timeout=300s
echo ""

# Display resources
print_colored "$BLUE" "===== Deployment Status ====="
print_colored "$YELLOW" "All resources have been deployed. Status:"
echo ""

print_colored "$YELLOW" "Pods:"
echo ""
kubectl get pods
echo ""

print_colored "$YELLOW" "Services:"
echo ""
kubectl get services
echo ""

print_colored "$YELLOW" "StatefulSets:"
echo ""
kubectl get statefulsets
echo ""

print_colored "$YELLOW" "Persistent Volume Claims:"
echo ""
kubectl get pvc
echo ""

print_colored "$BLUE" "===== MongoDB Access Information ====="
print_colored "$YELLOW" "MongoDB can be accessed using these service endpoints:"
print_colored "$YELLOW" "  - For load-balanced access: mongodb.statefulset-demo.svc.cluster.local:27017"
print_colored "$YELLOW" "  - For direct access to specific pods:"
print_colored "$YELLOW" "    * mongodb-0.mongodb-headless.statefulset-demo.svc.cluster.local:27017"
print_colored "$YELLOW" "    * mongodb-1.mongodb-headless.statefulset-demo.svc.cluster.local:27017"
print_colored "$YELLOW" "    * mongodb-2.mongodb-headless.statefulset-demo.svc.cluster.local:27017"
echo ""

print_colored "$YELLOW" "MongoDB Replica Set can be accessed using:"
print_colored "$YELLOW" "  - mongodb-cluster-0.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017 (primary)"
print_colored "$YELLOW" "  - mongodb-cluster-1.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017 (secondary)"
print_colored "$YELLOW" "  - mongodb-cluster-2.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017 (secondary)"
echo ""

print_colored "$BLUE" "===== MongoDB Admin UI Access ====="
print_colored "$YELLOW" "MongoDB Admin UI is available at: http://mongodb-admin.example.com"
print_colored "$YELLOW" "(You need to map this hostname in your /etc/hosts file or configure DNS accordingly)"
print_colored "$YELLOW" "Credentials: admin / pass"
echo ""

print_colored "$BLUE" "===== Deployment Complete ====="
