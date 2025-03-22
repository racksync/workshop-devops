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

# Create Istio system namespace
print_headline "Creating istio-system namespace"
kubectl create namespace istio-system
echo ""

# Download and install Istio
print_headline "Downloading and installing Istio"
ISTIO_VERSION=1.18.2  # Specifying version for stability
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd istio-$ISTIO_VERSION

# Add istioctl to PATH for this session
export PATH=$PWD/bin:$PATH
echo ""

# Install Istio with demo profile
print_headline "Installing Istio with demo profile"
istioctl install --set profile=demo -y
echo ""

# Install addons for observability
print_headline "Installing observability addons (Prometheus, Grafana, Kiali, Jaeger)"
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/grafana.yaml
kubectl apply -f samples/addons/kiali.yaml
kubectl apply -f samples/addons/jaeger.yaml
echo ""

# Create and configure demo namespace
print_headline "Creating and configuring istio-demo namespace"
kubectl create namespace istio-demo
kubectl label namespace istio-demo istio-injection=enabled
kubectl config set-context --current --namespace=istio-demo
echo ""

# Deploy Bookinfo application
print_headline "Deploying Bookinfo sample application"
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
echo ""

# Wait for pods to be ready
print_headline "Waiting for Bookinfo pods to be ready"
kubectl wait --for=condition=ready pod --all --timeout=300s
echo ""

# Create Istio Gateway and Virtual Service
print_headline "Creating Istio Gateway and Virtual Service"
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
echo ""

# Apply destination rules
print_headline "Applying destination rules"
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
echo ""

# Apply custom Virtual Services and other configurations
print_headline "Applying custom routing and resilience configurations"
cd ..  # Moving back to the workshop directory

# Apply Virtual Service for A/B testing
kubectl apply -f virtual-service-reviews-test-v2.yaml
print_success "Applied Virtual Service for A/B testing"
echo ""

# Apply Virtual Service for canary deployment
kubectl apply -f virtual-service-reviews-90-10.yaml
print_success "Applied Virtual Service for canary deployment"
echo ""

# Apply mTLS policy
kubectl apply -f peer-authentication.yaml
print_success "Applied mTLS policy"
echo ""

# Apply Circuit Breaker
kubectl apply -f destination-rule-circuit-breaker.yaml
print_success "Applied Circuit Breaker configuration"
echo ""

# Apply Fault Injection
kubectl apply -f virtual-service-ratings-delay.yaml
print_success "Applied Fault Injection configuration"
echo ""

# Show external access information
print_headline "External Access Information"
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$INGRESS_HOST" ]; then
    INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
fi

if [ -z "$INGRESS_HOST" ]; then
    # For minikube or environments without load balancer
    INGRESS_HOST="demo.k8s.local"
    print_info "No external load balancer found. Using demo.k8s.local"
    print_info "Please add the following entry to your /etc/hosts file:"
    print_info "127.0.0.1    demo.k8s.local"
fi

GATEWAY_URL="${INGRESS_HOST}:${INGRESS_PORT}"
echo ""
print_success "Bookinfo application URL: http://$GATEWAY_URL/productpage"
echo ""
print_headline "Setup complete!"
print_info "To access Kiali dashboard, run: istioctl dashboard kiali"
print_info "To access Grafana dashboard, run: istioctl dashboard grafana"
print_info "To access Jaeger dashboard, run: istioctl dashboard jaeger"
print_info "Or run the dashboard.sh script"
echo ""
