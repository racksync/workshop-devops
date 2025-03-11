#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== StatefulSet Behavior Test =====${NC}"
echo -e "${YELLOW}This script demonstrates key behaviors of StatefulSets in Kubernetes${NC}"

# Make sure we're in the correct namespace
echo -e "${GREEN}Setting context to statefulset-demo namespace...${NC}"
kubectl config set-context --current --namespace=statefulset-demo
echo

# Check if StatefulSet is deployed
echo -e "${CYAN}Checking if MongoDB StatefulSet is deployed...${NC}"
if ! kubectl get statefulset mongodb &>/dev/null; then
    echo -e "${RED}MongoDB StatefulSet not found! Please run deploy.sh first.${NC}"
    exit 1
fi
echo -e "${GREEN}StatefulSet found! Continuing with tests...${NC}"
echo

# Test 1: Show ordered creation of pods
echo -e "${BLUE}===== Test 1: Ordered Creation =====${NC}"
echo -e "${YELLOW}Scaling down to 0 replicas...${NC}"
kubectl scale statefulset mongodb --replicas=0
echo -e "${YELLOW}Waiting for scale down...${NC}"
kubectl wait --for=jsonpath='{.status.replicas}'=0 statefulset/mongodb --timeout=60s
echo

echo -e "${YELLOW}Scaling up to 3 replicas and observing ordered creation...${NC}"
kubectl scale statefulset mongodb --replicas=3

echo -e "${CYAN}Watching pod creation order (press Ctrl+C when all pods are Running)...${NC}"
echo -e "${CYAN}Expected behavior: Pods will be created in order (mongodb-0, mongodb-1, mongodb-2)${NC}"
kubectl get pods -w -l app=mongodb

# Wait for all pods to be ready
echo -e "${YELLOW}Waiting for all pods to be ready...${NC}"
kubectl rollout status statefulset/mongodb --timeout=120s
echo

# Test 2: Persistent storage
echo -e "${BLUE}===== Test 2: Persistent Storage =====${NC}"
echo -e "${CYAN}Let's add some test data to mongodb-0 and verify it persists across restarts${NC}"

echo -e "${YELLOW}Creating test data in mongodb-0...${NC}"
kubectl exec -it mongodb-0 -- mongo --eval '
   db.getSiblingDB("admin").auth("admin", "password");
   db.getSiblingDB("test").createCollection("demo");
   db.getSiblingDB("test").demo.insertOne({
      test_id: "statefulset-test",
      message: "This data should persist",
      timestamp: new Date()
   });
   db.getSiblingDB("test").demo.find();
'
echo

echo -e "${YELLOW}Deleting mongodb-0 pod (it will be recreated by the StatefulSet controller)...${NC}"
kubectl delete pod mongodb-0
echo -e "${YELLOW}Waiting for mongodb-0 to be recreated and ready...${NC}"
kubectl wait --for=condition=Ready pod/mongodb-0 --timeout=60s
echo

echo -e "${YELLOW}Checking if our data is still there...${NC}"
kubectl exec -it mongodb-0 -- mongo --eval '
   db.getSiblingDB("admin").auth("admin", "password");
   db.getSiblingDB("test").demo.find({test_id: "statefulset-test"});
'
echo
echo -e "${CYAN}If you see the data above, it means the PVC successfully preserved our data!${NC}"
echo

# Test 3: Stable network identity
echo -e "${BLUE}===== Test 3: Stable Network Identity =====${NC}"
echo -e "${CYAN}Let's check the DNS entries for our StatefulSet pods${NC}"

echo -e "${YELLOW}Creating a debug pod for DNS lookup...${NC}"
kubectl run -i --tty --rm debug --image=tutum/dnsutils --restart=Never -- bash -c '
echo "Checking DNS for mongodb-0:"
nslookup mongodb-0.mongodb-headless.statefulset-demo.svc.cluster.local

echo -e "\nChecking DNS for mongodb-1:"
nslookup mongodb-1.mongodb-headless.statefulset-demo.svc.cluster.local

echo -e "\nChecking DNS for mongodb-2:" 
nslookup mongodb-2.mongodb-headless.statefulset-demo.svc.cluster.local

echo -e "\nChecking direct connection to mongodb-0:"
nc -zv mongodb-0.mongodb-headless.statefulset-demo.svc.cluster.local 27017

echo -e "\nChecking load-balanced service:"
nslookup mongodb.statefulset-demo.svc.cluster.local
' || true
echo

# Test 4: Ordered scaling
echo -e "${BLUE}===== Test 4: Ordered Scaling =====${NC}"
echo -e "${CYAN}StatefulSets scale up in ascending order and scale down in descending order${NC}"

echo -e "${YELLOW}Scaling down to 1 replica...${NC}"
kubectl scale statefulset mongodb --replicas=1
echo -e "${CYAN}Watching pod termination order...${NC}"
echo -e "${CYAN}Expected behavior: Pods will be terminated in reverse order (mongodb-2, mongodb-1)${NC}"
kubectl get pods -w -l app=mongodb & 
WATCH_PID=$!
sleep 20  # Give some time to observe
kill $WATCH_PID
wait $WATCH_PID 2>/dev/null
echo

echo -e "${YELLOW}Scaling back to 3 replicas...${NC}"
kubectl scale statefulset mongodb --replicas=3
echo -e "${YELLOW}Waiting for scale up to complete...${NC}"
kubectl rollout status statefulset/mongodb --timeout=120s
echo

# Test 5: MongoDB Replica Set Demonstration
echo -e "${BLUE}===== Test 5: MongoDB Replica Set =====${NC}"
echo -e "${CYAN}Let's check the status of our MongoDB Cluster Replica Set${NC}"

echo -e "${YELLOW}Checking the replica set status from primary node...${NC}"
kubectl exec -it mongodb-cluster-0 -- mongo --eval '
   rs.status();
'

# Summary
echo
echo -e "${BLUE}===== StatefulSet Behavior Test Summary =====${NC}"
echo -e "${GREEN}We've demonstrated key StatefulSet behaviors:${NC}"
echo -e "  ${CYAN}1. Ordered pod creation and deletion${NC}"
echo -e "  ${CYAN}2. Persistent storage that survives pod restarts${NC}"
echo -e "  ${CYAN}3. Stable network identity through headless services${NC}"
echo -e "  ${CYAN}4. Controlled scaling operations${NC}"
echo -e "  ${CYAN}5. Complex stateful application deployment (MongoDB Replica Set)${NC}"
echo
echo -e "${YELLOW}These features make StatefulSets ideal for stateful applications like databases,${NC}"
echo -e "${YELLOW}distributed storage systems, and other applications that require:${NC}"
echo -e "  - Stable, unique network identifiers"
echo -e "  - Stable, persistent storage"
echo -e "  - Ordered, graceful deployment and scaling"
echo -e "  - Ordered, automated rolling updates"
echo
echo -e "${BLUE}===== Test Complete =====${NC}"
