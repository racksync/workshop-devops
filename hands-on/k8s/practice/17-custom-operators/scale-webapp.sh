#!/bin/bash

# Functions for colored output
function headline() {
  echo -e "\033[1;33m$1\033[0m"
}

function info() {
  echo -e "\033[0;36m$1\033[0m"
}

function success() {
  echo -e "\033[0;32m$1\033[0m"
}

function error() {
  echo -e "\033[0;31m$1\033[0m"
}

# Check if webapp name is provided
if [ -z "$1" ]; then
  error "Please provide a WebApp name to scale"
  info "Usage: $0 <webapp-name> <replica-count>"
  info "Example: $0 sample-webapp 5"
  exit 1
fi

# Check if replica count is provided
if [ -z "$2" ] || ! [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
  error "Please provide a valid replica count (must be a positive integer)"
  info "Usage: $0 <webapp-name> <replica-count>"
  info "Example: $0 sample-webapp 5"
  exit 1
fi

WEBAPP_NAME=$1
REPLICA_COUNT=$2

# Check if the namespace exists
if ! kubectl get namespace operator-demo &> /dev/null; then
  error "Namespace operator-demo does not exist. Please run deploy.sh first."
  exit 1
fi

# Set context to operator-demo namespace
kubectl config set-context --current --namespace=operator-demo

# Check if the specified WebApp exists
if ! kubectl get webapp "$WEBAPP_NAME" &> /dev/null; then
  error "WebApp '$WEBAPP_NAME' not found in namespace operator-demo"
  info "Available WebApps:"
  kubectl get webapps
  exit 1
fi

headline "Scaling WebApp: $WEBAPP_NAME to $REPLICA_COUNT replicas"
echo ""

# Get current replica count
CURRENT_REPLICAS=$(kubectl get webapp "$WEBAPP_NAME" -o jsonpath='{.spec.size}')
info "Current replica count: $CURRENT_REPLICAS"
echo ""

# Scale the WebApp
info "Scaling WebApp..."
kubectl patch webapp "$WEBAPP_NAME" --type=merge -p "{\"spec\":{\"size\":$REPLICA_COUNT}}"
echo ""

# Wait for scaling operation
info "Waiting for scaling operation to complete..."
sleep 5
echo ""

# Check the status
info "Current status of WebApp:"
kubectl get webapp "$WEBAPP_NAME"
echo ""

# Watch pods being created/terminated
info "Watching pods (press Ctrl+C to exit):"
kubectl get pods -w -l "app.kubernetes.io/instance=$WEBAPP_NAME"
