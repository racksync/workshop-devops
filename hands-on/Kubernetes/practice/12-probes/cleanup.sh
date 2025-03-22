#!/bin/bash

# Define color functions
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
}

function print_info() {
    echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

# Save current namespace
CURRENT_NS=$(kubectl config view --minify --output 'jsonpath={..namespace}')

# Delete all resources in probes-demo namespace
print_headline "Cleaning up all resources in 'probes-demo' namespace..."
kubectl delete pod liveness-http --namespace=probes-demo --ignore-not-found
kubectl delete pod readiness-http --namespace=probes-demo --ignore-not-found
kubectl delete pod startup-probe --namespace=probes-demo --ignore-not-found
kubectl delete pod exec-probe --namespace=probes-demo --ignore-not-found
kubectl delete pod tcp-probe --namespace=probes-demo --ignore-not-found
kubectl delete pod failing-probe --namespace=probes-demo --ignore-not-found
kubectl delete deployment app-with-probes --namespace=probes-demo --ignore-not-found

echo ""

# Delete namespace
print_headline "Deleting 'probes-demo' namespace..."
kubectl delete namespace probes-demo

echo ""

# Set context back to default namespace if current namespace was probes-demo
if [ "$CURRENT_NS" == "probes-demo" ]; then
    print_headline "Setting context back to 'default' namespace..."
    kubectl config set-context --current --namespace=default
    print_info "Context set to 'default' namespace."
else
    print_info "Current namespace '$CURRENT_NS' preserved."
fi

echo ""
print_info "Cleanup completed! All resources related to the probe exercise have been removed."
