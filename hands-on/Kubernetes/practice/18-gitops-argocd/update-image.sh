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

# Check if yq is installed (needed for YAML manipulation)
if ! command -v yq &> /dev/null; then
    print_error "yq could not be found. Please install yq for YAML processing"
    print_info "You can install it with: pip install yq or wget https://github.com/mikefarah/yq/releases/"
    exit 1
fi

print_headline "GitOps Image Update Simulation"
print_info "This script simulates updating an image tag in a GitOps workflow"
echo ""

# Get new image tag from user
read -p "Enter new image tag (e.g., 1.21): " IMAGE_TAG

if [ -z "$IMAGE_TAG" ]; then
    print_error "No image tag provided. Using default: 1.21"
    IMAGE_TAG="1.21"
fi

FULL_IMAGE="nginx:$IMAGE_TAG"

print_info "Creating a temporary directory to simulate Git operations..."
TEMP_DIR=$(mktemp -d)
echo ""

print_info "Copying application manifests to temporary directory..."
mkdir -p $TEMP_DIR/yaml/overlays/dev
cp -r ./yaml/base $TEMP_DIR/yaml/
cp -r ./yaml/overlays/dev/* $TEMP_DIR/yaml/overlays/dev/
echo ""

print_info "Updating image tag in deployment-patch.yaml to $FULL_IMAGE"
# Using sed as a more common alternative to yq
sed -i.bak "s|image: nginx:.*|image: $FULL_IMAGE|g" $TEMP_DIR/yaml/overlays/dev/deployment-patch.yaml
echo ""

print_info "Updated manifest content:"
cat $TEMP_DIR/yaml/overlays/dev/deployment-patch.yaml
echo ""

print_headline "In a real GitOps workflow:"
print_info "1. This change would be committed to the Git repository"
print_info "2. ArgoCD would detect the change and update the deployment"
print_info "3. The application would be running with the new image"
echo ""

print_info "Simulating the application of the changes manually:"
kubectl apply -k $TEMP_DIR/yaml/overlays/dev/
echo ""

print_info "Current deployment image:"
sleep 5
kubectl -n development get deployment dev-sample-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
echo ""

print_headline "Note about GitOps Principles"
print_info "In a true GitOps workflow, you would NEVER apply changes directly with kubectl"
print_info "Instead, ArgoCD should be the ONLY entity making changes to the cluster"
print_info "All changes should be made to the Git repository, which ArgoCD watches"
echo ""

print_headline "Cleaning up"
print_info "Removing temporary directory..."
rm -rf $TEMP_DIR
echo ""

print_success "Image update simulation completed!"
echo ""
