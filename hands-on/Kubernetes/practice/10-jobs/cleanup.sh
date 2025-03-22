#!/bin/bash
# This script deletes all resources created for the Jobs and CronJobs workshop

# Define color functions for better readability
info() {
    printf "\033[0;34m%s\033[0m\n" "$1"
    echo ""
}

success() {
    printf "\033[0;32m%s\033[0m\n" "$1"
    echo ""
}

error() {
    printf "\033[0;31m%s\033[0m\n" "$1"
    echo ""
}

headline() {
    printf "\033[1;36m%s\033[0m\n" "$1"
    echo ""
}

# Start cleanup process
headline "Kubernetes Jobs and CronJobs Workshop - Cleanup"

info "Setting namespace to delete"
NAMESPACE="jobs-demo"

info "Deleting all resources in the namespace"
kubectl delete cronjobs --all -n $NAMESPACE
kubectl delete jobs --all -n $NAMESPACE

info "Verifying deletion of resources"
kubectl get jobs,cronjobs -n $NAMESPACE

info "Deleting the namespace"
kubectl delete namespace $NAMESPACE

success "All workshop resources have been deleted successfully!"
