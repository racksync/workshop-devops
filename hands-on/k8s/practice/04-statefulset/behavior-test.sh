#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored text
print_colored() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

print_colored "$BLUE" "===== StatefulSet Behavior Test ====="
print_colored "$YELLOW" "This script demonstrates key behaviors of StatefulSets in Kubernetes"
echo ""

# Make sure we're in the correct namespace
print_colored "$GREEN" "Setting context to statefulset-demo namespace..."
kubectl config set-context --current --namespace=statefulset-demo
echo ""

# Check if StatefulSet is deployed
print_colored "$CYAN" "Checking if MongoDB StatefulSet is deployed..."
echo ""
if ! kubectl get statefulset mongodb &>/dev/null; then
    print_colored "$RED" "MongoDB StatefulSet not found! Please run deploy.sh first."
    exit 1
fi
print_colored "$GREEN" "StatefulSet found! Continuing with tests..."
echo ""

# Test 1: Show ordered creation of pods
print_colored "$BLUE" "===== Test 1: Ordered Creation ====="
print_colored "$YELLOW" "Scaling down to 0 replicas..."
echo ""
kubectl scale statefulset mongodb --replicas=0
print_colored "$YELLOW" "Waiting for scale down..."
echo ""
kubectl wait --for=jsonpath='{.status.replicas}'=0 statefulset/mongodb --timeout=60s
echo ""

print_colored "$YELLOW" "Scaling up to 3 replicas and observing ordered creation..."
echo ""
kubectl scale statefulset mongodb --replicas=3

print_colored "$CYAN" "Watching pod creation order (press Ctrl+C when all pods are Running)..."
print_colored "$CYAN" "Expected behavior: Pods will be created in order (mongodb-0, mongodb-1, mongodb-2)"
echo ""
kubectl get pods -w -l app=mongodb

# Wait for all pods to be ready
print_colored "$YELLOW" "Waiting for all pods to be ready..."
echo ""
kubectl rollout status statefulset/mongodb --timeout=120s
echo ""

# Test 2: Persistent storage
print_colored "$BLUE" "===== Test 2: Persistent Storage ====="
print_colored "$CYAN" "Let's add some test data to mongodb-0 and verify it persists across restarts"
echo ""

print_colored "$YELLOW" "Creating test data in mongodb-0..."
echo ""
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
echo ""

print_colored "$YELLOW" "Deleting mongodb-0 pod (it will be recreated by the StatefulSet controller)..."
echo ""
kubectl delete pod mongodb-0
print_colored "$YELLOW" "Waiting for mongodb-0 to be recreated and ready..."
echo ""
kubectl wait --for=condition=Ready pod/mongodb-0 --timeout=60s
echo ""

print_colored "$YELLOW" "Checking if our data is still there..."
echo ""
kubectl exec -it mongodb-0 -- mongo --eval '
   db.getSiblingDB("admin").auth("admin", "password");
   db.getSiblingDB("test").demo.find({test_id: "statefulset-test"});
'
echo ""
print_colored "$CYAN" "If you see the data above, it means the PVC successfully preserved our data!"
echo ""

# Test 3: Stable network identity
print_colored "$BLUE" "===== Test 3: Stable Network Identity ====="
print_colored "$CYAN" "Let's check the DNS entries for our StatefulSet pods"
echo ""

print_colored "$YELLOW" "Creating a debug pod for DNS lookup..."
echo ""
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
echo ""

# Test 4: Ordered scaling
print_colored "$BLUE" "===== Test 4: Ordered Scaling ====="
print_colored "$CYAN" "StatefulSets scale up in ascending order and scale down in descending order"
echo ""

print_colored "$YELLOW" "Scaling down to 1 replica..."
echo ""
kubectl scale statefulset mongodb --replicas=1
print_colored "$CYAN" "Watching pod termination order..."
print_colored "$CYAN" "Expected behavior: Pods will be terminated in reverse order (mongodb-2, mongodb-1)"
echo ""
kubectl get pods -w -l app=mongodb & 
WATCH_PID=$!
sleep 20  # Give some time to observe
kill $WATCH_PID
wait $WATCH_PID 2>/dev/null
echo ""

print_colored "$YELLOW" "Scaling back to 3 replicas..."
echo ""
kubectl scale statefulset mongodb --replicas=3
print_colored "$YELLOW" "Waiting for scale up to complete..."
echo ""
kubectl rollout status statefulset/mongodb --timeout=120s
echo ""

# Test 5: MongoDB Replica Set Demonstration
print_colored "$BLUE" "===== Test 5: MongoDB Replica Set ====="
print_colored "$CYAN" "Let's check the status of our MongoDB Cluster Replica Set"
echo ""

print_colored "$YELLOW" "Checking the replica set status from primary node..."
echo ""
kubectl exec -it mongodb-cluster-0 -- mongo --eval '
   rs.status();
'

# Summary
echo ""
print_colored "$BLUE" "===== StatefulSet Behavior Test Summary ====="
print_colored "$GREEN" "We've demonstrated key StatefulSet behaviors:"
echo -e "  ${CYAN}1. Ordered pod creation and deletion${NC}"
echo -e "  ${CYAN}2. Persistent storage that survives pod restarts${NC}"
echo -e "  ${CYAN}3. Stable network identity through headless services${NC}"
echo -e "  ${CYAN}4. Controlled scaling operations${NC}"
echo -e "  ${CYAN}5. Complex stateful application deployment (MongoDB Replica Set)${NC}"
echo ""
print_colored "$YELLOW" "These features make StatefulSets ideal for stateful applications like databases,"
print_colored "$YELLOW" "distributed storage systems, and other applications that require:"
echo -e "  - Stable, unique network identifiers"
echo -e "  - Stable, persistent storage"
echo -e "  - Ordered, graceful deployment and scaling"
echo -e "  - Ordered, automated rolling updates"
echo ""
print_colored "$BLUE" "===== Test Complete ====="
