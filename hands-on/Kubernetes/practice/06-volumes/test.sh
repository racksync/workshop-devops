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

# Ensure we're in the volume-demo namespace
kubectl config set-context --current --namespace=volume-demo

# Check if all pods are running
print_headline "Checking pod status..."
kubectl get pods
echo ""

# Test emptyDir volume
print_headline "Testing emptyDir volume (shared data between containers)..."
echo "Checking logs from reader container that reads data written by writer container:"
kubectl logs emptydir-pod -c reader | tail -n 5
echo ""

# Test hostPath volume
print_headline "Testing hostPath volume..."
echo "Creating test file in nginx web root through the pod:"
kubectl exec hostpath-pod -- sh -c 'echo "<h1>Hello from hostPath volume!</h1>" > /usr/share/nginx/html/index.html'
echo "Verifying file content:"
kubectl exec hostpath-pod -- cat /usr/share/nginx/html/index.html
echo ""

# Check Ingress and Service
print_headline "Checking Nginx Service and Ingress..."
echo "Service:"
kubectl get svc nginx-service
echo ""
echo "Ingress:"
kubectl get ingress nginx-ingress
echo ""
echo "To test the Nginx server from your browser, visit: http://demo.k8s.local"
echo "(Make sure demo.k8s.local points to your cluster's ingress controller in /etc/hosts)"
echo ""

# Test PersistentVolume and PVC
print_headline "Testing PersistentVolumeClaim..."
echo "Checking PV and PVC status:"
kubectl get pv
kubectl get pvc
echo ""
echo "Checking data written to PVC by the pod:"
kubectl exec pvc-pod -- cat /mnt/data/output.txt | tail -n 5
echo ""

# Test ConfigMap as volume
print_headline "Testing ConfigMap as volume..."
echo "Checking config file mounted from ConfigMap:"
kubectl logs configmap-pod
echo ""

# Test Secret as volume
print_headline "Testing Secret as volume..."
echo "Checking secret data mounted as files:"
kubectl logs secret-pod
echo ""

# Test StorageClass
print_headline "Testing StorageClass and dynamic provisioning..."
echo "Checking StorageClass:"
kubectl get storageclass
echo ""
echo "Checking dynamically provisioned PVC:"
kubectl get pvc dynamic-pvc
echo ""

print_headline "Hostname Configuration Note:"
print_info "If you need to use the hostname demo.k8s.local for this exercise, add the following line to your /etc/hosts file:"
echo "127.0.0.1 demo.k8s.local"
echo ""

print_success "All tests completed successfully!"
print_info "When you're done with the workshop, run './cleanup.sh' to delete all resources."
