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

print_headline "GitOps CD Pipeline with ArgoCD - Cleanup"
print_info "This script will remove all resources created in this exercise"
echo ""

# Ask for confirmation before proceeding
read -p "Are you sure you want to delete all resources? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Cleanup cancelled"
    exit 0
fi

print_info "Deleting sample applications from ArgoCD"
kubectl -n argocd delete applications --all
echo ""

print_info "Waiting for application resources to be removed..."
sleep 10
echo ""

print_info "Deleting development namespace"
kubectl delete namespace development --ignore-not-found
echo ""

print_info "Deleting Argo Rollouts namespace"
kubectl delete namespace argo-rollouts --ignore-not-found
echo ""

print_info "Deleting ArgoCD resources"
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo ""

print_info "Deleting ArgoCD namespace"
kubectl delete namespace argocd --ignore-not-found
echo ""

print_info "Switching kubectl context to default namespace"
kubectl config set-context --current --namespace=default
echo ""

print_success "Cleanup completed successfully! All resources have been removed."
echo ""
