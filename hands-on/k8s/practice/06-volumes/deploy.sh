#!/bin/bash

# Color function definitions
function print_info() {
    echo -e "\033[1;34m$1\033[0m"
}

function print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

function print_headline() {
    echo -e "\033[1;33m$1\033[0m"
}

# Create namespace and set context
print_headline "Creating namespace and setting context..."
kubectl create namespace volume-demo
kubectl config set-context --current --namespace=volume-demo

echo ""

# Create emptyDir pod
print_headline "Creating Pod with emptyDir volume..."
kubectl apply -f emptydir-pod.yaml
echo ""

# Create hostPath pod
print_headline "Creating Pod with hostPath volume..."
kubectl apply -f hostpath-pod.yaml
echo ""

# Create nginx service and ingress
print_headline "Creating Nginx Service and Ingress..."
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-ingress.yaml
echo "Creating default index.html in hostPath volume..."
kubectl exec hostpath-pod -- sh -c 'echo "<h1>Welcome to Kubernetes Volumes Demo!</h1><p>This page is served from a hostPath volume</p>" > /usr/share/nginx/html/index.html'
echo ""

# Create persistent volume resources
print_headline "Creating PersistentVolume and PersistentVolumeClaim..."
kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml
echo ""

# Create pod using PVC
print_headline "Creating Pod using PersistentVolumeClaim..."
kubectl apply -f pvc-pod.yaml
echo ""

# Create ConfigMap and Secret volumes
print_headline "Creating ConfigMap and Secret volumes..."
kubectl apply -f config-volume.yaml
kubectl apply -f secret-volume.yaml
echo ""

# Create StorageClass example (if cluster supports)
print_headline "Creating StorageClass example..."
kubectl apply -f storage-class-example.yaml
echo ""

# Wait for all pods to be ready
print_headline "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pods --all --timeout=60s

echo ""
print_success "All resources have been deployed successfully!"
print_info "Run './test.sh' to test the resources."
print_info "Run './cleanup.sh' to delete all resources when finished."
