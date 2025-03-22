#!/bin/bash

# Color functions
function print_info() {
    echo -e "\033[0;34m$1\033[0m"
}

function print_success() {
    echo -e "\033[0;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

function print_headline() {
    echo -e "\033[1;33m$1\033[0m"
}

print_headline "Starting cleanup of Istio resources"

# Switch to istio-demo namespace
kubectl config set-context --current --namespace=istio-demo
echo ""

# Delete Bookinfo application
print_info "Removing Bookinfo application"
ISTIO_DIR=$(find $HOME -name "istio-*" -type d | head -n 1)

if [ -d "$ISTIO_DIR" ]; then
    kubectl delete -f $ISTIO_DIR/samples/bookinfo/platform/kube/bookinfo.yaml
    echo ""
    
    # Delete routing rules and gateway
    print_info "Removing routing rules and gateway"
    kubectl delete -f $ISTIO_DIR/samples/bookinfo/networking/bookinfo-gateway.yaml
    echo ""
    
    # Remove custom configurations
    print_info "Removing custom configurations"
    kubectl delete virtualservices --all
    kubectl delete destinationrules --all
    kubectl delete peerauthentications --all
    echo ""
else
    print_error "Istio directory not found. Trying to delete resources directly."
    kubectl delete -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
    kubectl delete -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/bookinfo-gateway.yaml
    kubectl delete virtualservices --all
    kubectl delete destinationrules --all
    kubectl delete peerauthentications --all
    echo ""
fi

# Switch to default namespace
print_info "Switching to default namespace"
kubectl config set-context --current --namespace=default
echo ""

# Delete the istio-demo namespace
print_info "Deleting istio-demo namespace"
kubectl delete namespace istio-demo
echo ""

# Ask if user wants to uninstall Istio completely
print_headline "Do you want to uninstall Istio completely? (y/n)"
read -r response
echo ""

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Find istioctl in PATH
    ISTIOCTL=$(which istioctl 2>/dev/null)
    
    if [ -z "$ISTIOCTL" ] && [ -d "$ISTIO_DIR" ]; then
        # If istioctl not in PATH but Istio directory exists
        ISTIOCTL="$ISTIO_DIR/bin/istioctl"
    fi
    
    if [ -n "$ISTIOCTL" ]; then
        print_info "Uninstalling Istio completely"
        $ISTIOCTL uninstall --purge -y
        
        # Delete the istio-system namespace
        print_info "Deleting istio-system namespace"
        kubectl delete namespace istio-system
        echo ""
    else
        print_error "istioctl not found. Please uninstall Istio manually."
        print_info "You can try:"
        print_info "istioctl uninstall --purge"
        print_info "kubectl delete namespace istio-system"
        echo ""
    fi
else
    print_info "Keeping Istio installation intact"
    echo ""
fi

print_success "Cleanup completed!"
echo ""
