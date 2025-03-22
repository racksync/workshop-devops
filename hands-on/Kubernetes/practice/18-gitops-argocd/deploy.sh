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

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl could not be found. Please install kubectl first."
    exit 1
fi

print_headline "GitOps CD Pipeline with ArgoCD Deployment"
print_info "This script will deploy ArgoCD and set up a sample GitOps pipeline"
echo ""

print_info "Creating ArgoCD namespace"
kubectl create namespace argocd
echo ""

print_info "Switching to ArgoCD namespace"
kubectl config set-context --current --namespace=argocd
echo ""

print_info "Deploying ArgoCD"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo ""

print_info "Waiting for ArgoCD pods to be ready (this may take a few minutes)..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
echo ""

print_success "ArgoCD has been deployed successfully!"
echo ""

print_info "Creating development namespace for sample application"
kubectl create namespace development
echo ""

print_info "Applying sample application manifests"
kubectl apply -f ./yaml/argocd-app.yaml
echo ""

print_headline "Setting up port-forwarding for ArgoCD UI"
print_info "Run the following command in a separate terminal to access ArgoCD UI:"
print_info "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
print_info "Then access ArgoCD UI at: https://localhost:8080"
echo ""

print_headline "ArgoCD admin credentials"
print_info "Username: admin"
print_info "Password: (retrieving...)"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
print_success "Password: $ARGOCD_PASSWORD"
echo ""

print_headline "Host Configuration"
print_info "If you want to use a custom hostname for ArgoCD, add the following to your /etc/hosts file:"
print_info "127.0.0.1 demo.k8s.local"
echo ""

print_success "Deployment complete! Your GitOps environment is ready."
print_info "Use the 'test.sh' script to test the deployment."
echo ""
