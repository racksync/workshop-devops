#!/bin/bash
# This script continuously monitors the status of Jobs and CronJobs in the workshop namespace

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

warning() {
    printf "\033[0;33m%s\033[0m\n" "$1"
    echo ""
}

# Set the namespace
NAMESPACE="jobs-demo"
kubectl config set-context --current --namespace=$NAMESPACE

headline "Kubernetes Jobs and CronJobs Monitoring Tool"
info "This script will continuously monitor the status of Jobs and CronJobs."
info "Press Ctrl+C to exit."

# Function to display current status
display_status() {
    clear
    headline "LIVE MONITORING - Updated every 5 seconds"
    
    headline "Jobs Status"
    kubectl get jobs
    echo ""
    
    headline "CronJobs Status"
    kubectl get cronjobs
    echo ""
    
    headline "Recent Pods from Jobs"
    kubectl get pods -l "job-name" --sort-by=.metadata.creationTimestamp | tail -5
    echo ""
    
    # Check for completed or failed jobs
    COMPLETED_JOBS=$(kubectl get jobs -o jsonpath='{.items[?(@.status.succeeded==1)].metadata.name}')
    FAILED_JOBS=$(kubectl get jobs -o jsonpath='{.items[?(@.status.failed>0)].metadata.name}')
    
    if [ -n "$COMPLETED_JOBS" ]; then
        success "Completed Jobs: $COMPLETED_JOBS"
    fi
    
    if [ -n "$FAILED_JOBS" ]; then
        error "Failed Jobs: $FAILED_JOBS"
    fi
}

# Main loop to continuously monitor
while true; do
    display_status
    sleep 5
done
