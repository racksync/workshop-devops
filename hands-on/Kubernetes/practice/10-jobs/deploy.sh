#!/bin/bash
# This script deploys all resources needed for the Jobs and CronJobs workshop

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

# Start deployment process
headline "Kubernetes Jobs and CronJobs Workshop - Deployment"

info "Creating namespace for workshop resources"
kubectl create namespace jobs-demo
kubectl config set-context --current --namespace=jobs-demo

info "Deploying basic job"
kubectl apply -f basic-job.yaml

info "Deploying job with completions and parallelism"
kubectl apply -f parallel-job.yaml

info "Deploying basic cronjob"
kubectl apply -f basic-cronjob.yaml

info "Deploying advanced cronjob with additional options"
kubectl apply -f advanced-cronjob.yaml

info "Deploying job that demonstrates failure handling"
kubectl apply -f failure-handling-job.yaml

success "All resources deployed successfully! The workshop environment is ready."
info "You can now run './test.sh' to see the status of all resources."
