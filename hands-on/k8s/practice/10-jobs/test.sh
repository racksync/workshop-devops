#!/bin/bash
# This script tests the status of Jobs and CronJobs in the workshop namespace

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

# Start testing process
headline "Kubernetes Jobs and CronJobs Workshop - Testing"

info "Setting namespace for testing"
NAMESPACE="jobs-demo"
kubectl config set-context --current --namespace=$NAMESPACE

headline "Jobs Status"
info "Checking all Jobs in the namespace"
kubectl get jobs

info "Checking details of the hello-world-job"
kubectl describe job hello-world-job

headline "CronJobs Status"
info "Checking all CronJobs in the namespace"
kubectl get cronjobs

info "Checking details of the hello-cronjob"
kubectl describe cronjob hello-cronjob

headline "Pod Status"
info "Checking pods created by Jobs"
kubectl get pods --selector=job-name=hello-world-job

info "Checking pods created by parallel job"
kubectl get pods --selector=job-name=parallel-job

headline "Logs"
info "Displaying logs from a job pod (if any exist)"
POD=$(kubectl get pods --selector=job-name=hello-world-job -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD" ]; then
    kubectl logs $POD
else
    info "No pods found for hello-world-job"
fi

success "Testing complete! This provides an overview of the Jobs and CronJobs running in the workshop environment."
