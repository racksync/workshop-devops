#!/bin/bash

# Define color functions
function print_info() {
    echo -e "\033[36m$1\033[0m"
}

function print_success() {
    echo -e "\033[32m$1\033[0m"
}

function print_error() {
    echo -e "\033[31m$1\033[0m"
}

function print_headline() {
    echo -e "\033[1;33m$1\033[0m"
}

print_headline "GitOps CD Pipeline with ArgoCD - Testing"
print_info "This script will perform various tests on the ArgoCD GitOps pipeline"
echo ""

# Check if ArgoCD is running
print_info "Checking if ArgoCD is running..."
if kubectl get namespace argocd &>/dev/null; then
    print_success "ArgoCD namespace exists"
    echo ""

    print_info "Checking ArgoCD server status..."
    if kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server | grep -q Running; then
        print_success "ArgoCD server is running"
    else
        print_error "ArgoCD server is not running. Please run deploy.sh first"
        exit 1
    fi
    echo ""
else
    print_error "ArgoCD namespace not found. Please run deploy.sh first"
    exit 1
fi

# Check sample application deployment
print_info "Checking sample application deployment status..."
if kubectl get namespace development &>/dev/null; then
    print_success "Development namespace exists"
    echo ""

    print_info "Checking for application resources in development namespace..."
    kubectl get all -n development
    echo ""
    
    print_info "Checking application sync status in ArgoCD..."
    kubectl -n argocd get applications
    echo ""
else
    print_error "Development namespace not found. Application may not be deployed"
    exit 1
fi

# Start port-forward for testing access
print_headline "Testing access to sample application"
print_info "Starting port-forward to the sample application service..."
kubectl -n development port-forward svc/dev-sample-app 8090:80 &
PORT_FORWARD_PID=$!
sleep 3
echo ""

print_info "Testing HTTP access to the application..."
curl -s localhost:8090 | head -n 10
echo ""

# Kill port-forward process
kill $PORT_FORWARD_PID 2>/dev/null

# Test GitOps workflow by simulating an update
print_headline "Simulating GitOps Workflow"
print_info "In a real GitOps workflow, you would update the Git repository and ArgoCD would apply the changes"
print_info "For this test, we will use kubectl to simulate a change and observe ArgoCD behavior"
echo ""

print_info "Manually updating the deployment image (this simulates a Git update)..."
kubectl -n development set image deployment/dev-sample-app sample-app=nginx:1.21
echo ""

print_info "Checking for drift detection by ArgoCD..."
print_info "ArgoCD should detect this change and revert it according to the GitOps principles"
echo ""

print_info "Waiting 30 seconds for ArgoCD to detect and reconcile..."
sleep 30
echo ""

print_info "Checking current deployment image version (should be reverted to the original):"
kubectl -n development get deployment dev-sample-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
echo ""

print_headline "Host Configuration Reminder"
print_info "For a complete experience, add the following to your /etc/hosts file:"
print_info "127.0.0.1 demo.k8s.local"
echo ""

print_success "Testing complete! Your GitOps pipeline is working as expected."
print_info "You can continue exploring ArgoCD functionality through the UI."
echo ""
