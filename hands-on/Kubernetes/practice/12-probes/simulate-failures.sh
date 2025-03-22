#!/bin/bash

# This script simulates different probe failures and demonstrates how Kubernetes responds

# Define color functions
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
}

function print_info() {
    echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
}

# Ensure we're in the probes-demo namespace
kubectl config set-context --current --namespace=probes-demo > /dev/null 2>&1

# Function to wait for pod to be ready
wait_for_pod() {
    local pod_name=$1
    local max_attempts=30
    local attempt=0
    
    print_info "Waiting for pod $pod_name to be ready..."
    
    while [ $attempt -lt $max_attempts ]; do
        pod_status=$(kubectl get pod $pod_name -o jsonpath='{.status.phase}' 2>/dev/null)
        
        if [[ "$pod_status" == "Running" ]]; then
            print_info "Pod $pod_name is now running."
            return 0
        fi
        
        sleep 2
        ((attempt++))
    done
    
    print_error "Pod $pod_name did not enter Running state within the timeout period."
    return 1
}

# 1. Simulating Liveness Probe Failure
print_headline "SIMULATING LIVENESS PROBE FAILURE"
print_info "Creating a pod that will have its liveness probe fail after 30 seconds..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: liveness-failure-demo
  namespace: probes-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    command:
    - /bin/sh
    - -c
    - "echo 'Starting nginx'; nginx -g 'daemon off;' & sleep 30; echo 'Removing health check path'; rm -rf /usr/share/nginx/html/healthz; sleep 600"
EOF

echo ""
wait_for_pod "liveness-failure-demo"

print_info "Created a temporary health endpoint that will be removed after 30 seconds..."
kubectl exec liveness-failure-demo -- bash -c "mkdir -p /usr/share/nginx/html/healthz"
kubectl exec liveness-failure-demo -- bash -c "echo 'OK' > /usr/share/nginx/html/healthz/index.html"

print_info "Initial pod state:"
kubectl get pod liveness-failure-demo
echo ""

print_info "Waiting 45 seconds for liveness probe to start failing..."
sleep 45

print_info "Pod state after liveness probe failure:"
kubectl get pod liveness-failure-demo
echo ""

print_info "Pod events showing restart due to liveness probe failure:"
kubectl describe pod liveness-failure-demo | grep -A 15 "Events:"
echo ""

# 2. Simulating Readiness Probe Failure
print_headline "SIMULATING READINESS PROBE FAILURE"
print_info "Creating a pod with a service that will have its readiness probe fail..."

# Create a deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: readiness-demo
  namespace: probes-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: readiness-demo
  template:
    metadata:
      labels:
        app: readiness-demo
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: readiness-demo
  namespace: probes-demo
spec:
  selector:
    app: readiness-demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo ""
sleep 10

print_info "Creating a readiness endpoint so the pod becomes ready..."
POD_NAME=$(kubectl get pods -l app=readiness-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- bash -c "mkdir -p /usr/share/nginx/html/ready"
kubectl exec $POD_NAME -- bash -c "echo 'READY' > /usr/share/nginx/html/ready/index.html"

print_info "Waiting for pod to become ready..."
sleep 10

print_info "Pod is now ready and included in service endpoints:"
kubectl get pod $POD_NAME
kubectl get endpoints readiness-demo
echo ""

print_info "Now removing readiness endpoint to make pod fail readiness check..."
kubectl exec $POD_NAME -- bash -c "rm -rf /usr/share/nginx/html/ready"

print_info "Waiting for readiness probe to fail..."
sleep 10

print_info "Pod is still running but should be removed from service endpoints:"
kubectl get pod $POD_NAME
kubectl get endpoints readiness-demo
echo ""

print_info "Pod events showing readiness probe failure:"
kubectl describe pod $POD_NAME | grep -A 15 "Events:"
echo ""

# 3. Cleanup simulation resources
print_headline "CLEANING UP SIMULATION RESOURCES"
kubectl delete pod liveness-failure-demo --ignore-not-found
kubectl delete deployment readiness-demo --ignore-not-found
kubectl delete service readiness-demo --ignore-not-found

echo ""
print_info "All simulation resources have been removed."
print_info "This demonstration showed how:"
print_info "1. Liveness probe failure causes a container restart"
print_info "2. Readiness probe failure removes the pod from service endpoints without restarting it"

# Hostname configuration note
echo ""
print_warning "NOTE: If you need to access services via hostname, add the following entry to your /etc/hosts file:"
print_warning "127.0.0.1 demo.k8s.local"
print_info "This allows you to access the services using http://demo.k8s.local in your browser."
echo ""

print_headline "Simulation script completed successfully!"
