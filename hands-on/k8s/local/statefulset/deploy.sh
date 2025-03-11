#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== StatefulSet Workshop Deployment =====${NC}"

# Create namespace
echo -e "${GREEN}Creating namespace...${NC}"
kubectl apply -f namespace.yaml
echo

# Set context to our namespace
echo -e "${GREEN}Setting context to statefulset-demo namespace...${NC}"
kubectl config set-context --current --namespace=statefulset-demo
echo

# Create headless service first (required for StatefulSet)
echo -e "${GREEN}Creating headless service for MongoDB...${NC}"
kubectl apply -f headless-service.yaml
echo

# Create regular service
echo -e "${GREEN}Creating regular ClusterIP service for MongoDB...${NC}"
kubectl apply -f service.yaml
echo

# Create StatefulSet
echo -e "${GREEN}Creating StatefulSet for MongoDB...${NC}"
kubectl apply -f statefulset.yaml
echo

# Wait for StatefulSet to be ready
echo -e "${YELLOW}Waiting for MongoDB StatefulSet to be ready...${NC}"
kubectl rollout status statefulset/mongodb --timeout=180s
echo

# MongoDB Admin UI
echo -e "${GREEN}Deploying MongoDB Admin UI (Mongo Express)...${NC}"
kubectl apply -f mongodb-admin-service.yaml
echo

# Ingress (if needed)
echo -e "${GREEN}Creating Ingress for MongoDB Admin UI...${NC}"
kubectl apply -f ingress.yaml
echo

# MongoDB Replica Set components
echo -e "${GREEN}Creating headless service for MongoDB Cluster...${NC}"
kubectl apply -f mongodb-cluster-headless-service.yaml
echo

echo -e "${GREEN}Creating StatefulSet for MongoDB Replica Set...${NC}"
kubectl apply -f statefulset-mongodb-cluster.yaml
echo

# Wait for the MongoDB Cluster StatefulSet to be ready
echo -e "${YELLOW}Waiting for MongoDB Cluster StatefulSet to be ready...${NC}"
kubectl rollout status statefulset/mongodb-cluster --timeout=300s
echo

# Display resources
echo -e "${BLUE}===== Deployment Status =====${NC}"
echo -e "${GREEN}All resources have been deployed. Status:${NC}"
echo
echo -e "${YELLOW}Pods:${NC}"
kubectl get pods
echo
echo -e "${YELLOW}Services:${NC}"
kubectl get services
echo
echo -e "${YELLOW}StatefulSets:${NC}"
kubectl get statefulsets
echo
echo -e "${YELLOW}Persistent Volume Claims:${NC}"
kubectl get pvc
echo
echo -e "${BLUE}===== MongoDB Access Information =====${NC}"
echo -e "MongoDB can be accessed using these service endpoints:"
echo -e "  - For load-balanced access: ${YELLOW}mongodb.statefulset-demo.svc.cluster.local:27017${NC}"
echo -e "  - For direct access to specific pods:"
echo -e "    * ${YELLOW}mongodb-0.mongodb-headless.statefulset-demo.svc.cluster.local:27017${NC}"
echo -e "    * ${YELLOW}mongodb-1.mongodb-headless.statefulset-demo.svc.cluster.local:27017${NC}"
echo -e "    * ${YELLOW}mongodb-2.mongodb-headless.statefulset-demo.svc.cluster.local:27017${NC}"
echo
echo -e "MongoDB Replica Set can be accessed using:"
echo -e "  - ${YELLOW}mongodb-cluster-0.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017${NC} (primary)"
echo -e "  - ${YELLOW}mongodb-cluster-1.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017${NC} (secondary)"
echo -e "  - ${YELLOW}mongodb-cluster-2.mongodb-cluster-headless.statefulset-demo.svc.cluster.local:27017${NC} (secondary)"
echo
echo -e "${BLUE}===== MongoDB Admin UI Access =====${NC}"
echo -e "MongoDB Admin UI is available at: ${YELLOW}http://mongodb-admin.example.com${NC}"
echo -e "(You need to map this hostname in your /etc/hosts file or configure DNS accordingly)"
echo -e "Credentials: admin / pass"
echo
echo -e "${BLUE}===== Deployment Complete =====${NC}"
