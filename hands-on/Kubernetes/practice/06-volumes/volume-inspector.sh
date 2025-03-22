#!/bin/bash

# Color function definitions
function print_info() {
    echo -e "\033[1;34m$1\033[0m"
}

function print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

function print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

function print_headline() {
    echo -e "\033[1;33m$1\033[0m"
}

# Ensure we're in the right namespace
kubectl config set-context --current --namespace=volume-demo

# Check if a pod name is provided
if [ $# -eq 0 ]; then
    print_error "No pod name provided."
    print_info "Usage: ./volume-inspector.sh <pod-name>"
    print_info "Available pods:"
    kubectl get pods -o name | sed 's/^pod\///'
    exit 1
fi

POD_NAME=$1

# Check if the pod exists
if ! kubectl get pod $POD_NAME &> /dev/null; then
    print_error "Pod '$POD_NAME' not found in namespace 'volume-demo'."
    exit 1
fi

# Display pod information
print_headline "Pod Information: $POD_NAME"
kubectl describe pod $POD_NAME | grep -A 10 "Volumes:"
echo ""

# Get list of volumes in the pod
VOLUMES=$(kubectl get pod $POD_NAME -o jsonpath='{.spec.volumes[*].name}')

# Check each volume
print_headline "Volume Details:"
for volume in $VOLUMES; do
    print_info "Volume: $volume"
    
    # Get volume type
    VOLUME_TYPE=$(kubectl get pod $POD_NAME -o jsonpath="{.spec.volumes[?(@.name==\"$volume\")]}") 
    echo "Volume Type: $(echo $VOLUME_TYPE | grep -o -E 'emptyDir|hostPath|persistentVolumeClaim|configMap|secret' | head -n 1)"

    # Get mount points for this volume
    print_info "Mount Points:"
    CONTAINERS=$(kubectl get pod $POD_NAME -o jsonpath='{.spec.containers[*].name}')
    for container in $CONTAINERS; do
        MOUNT=$(kubectl get pod $POD_NAME -o jsonpath="{.spec.containers[?(@.name==\"$container\")].volumeMounts[?(@.name==\"$volume\")].mountPath}" 2>/dev/null)
        if [ -n "$MOUNT" ]; then
            echo "  Container: $container, Path: $MOUNT"
            
            # If it's possible, list files in the volume
            echo "  Files in volume (if accessible):"
            kubectl exec $POD_NAME -c $container -- ls -la $MOUNT 2>/dev/null || echo "  Cannot list files (container may not be running or path not accessible)"
        fi
    done
    echo ""
done

# Display host path directories if hostPath volumes exist
if kubectl get pod $POD_NAME -o yaml | grep -q hostPath; then
    print_headline "Note about hostPath Volumes:"
    print_info "To inspect hostPath volumes on the node itself, you would need to:"
    echo "1. SSH into the Kubernetes node"
    echo "2. Navigate to the directory specified in the hostPath configuration"
    echo "3. Use standard Linux commands to inspect the files"
    
    # Show the hostPath directories
    print_info "hostPath directories used by this pod:"
    kubectl get pod $POD_NAME -o jsonpath='{range .spec.volumes[*]}{.hostPath.path}{"\n"}{end}' 2>/dev/null | grep -v "^$"
fi

echo ""
print_success "Volume inspection completed for pod: $POD_NAME"
print_info "For more detailed information, consider using 'kubectl describe pod $POD_NAME'"
print_info "To test connectivity to demo.k8s.local, ensure you've added it to your /etc/hosts file:"
echo "127.0.0.1 demo.k8s.local"
