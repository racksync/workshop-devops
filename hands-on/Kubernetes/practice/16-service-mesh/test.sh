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

# Check if host entry is present
function check_host_entry() {
    if grep -q "demo.k8s.local" /etc/hosts; then
        print_success "Host entry for demo.k8s.local found in /etc/hosts"
    else
        print_error "Host entry for demo.k8s.local not found in /etc/hosts"
        print_info "Please add the following entry to your /etc/hosts file:"
        print_info "127.0.0.1    demo.k8s.local"
    fi
    echo ""
}

# Function to test URL
function test_url() {
    local url=$1
    local desc=$2
    print_info "Testing $desc: $url"
    
    # Using curl with a 10-second timeout
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
    
    if [ "$status_code" -eq 200 ]; then
        print_success "✅ $desc is accessible (Status code: $status_code)"
    else
        print_error "❌ $desc is not accessible (Status code: $status_code)"
    fi
    echo ""
}

# Check if we are in the istio-demo namespace
current_ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$current_ns" != "istio-demo" ]; then
    print_info "Switching to istio-demo namespace"
    kubectl config set-context --current --namespace=istio-demo
    echo ""
fi

print_headline "Istio Service Mesh Test Script"
check_host_entry
echo ""

# Check if Istio is installed
print_headline "1. Checking Istio Installation"
if kubectl get namespace istio-system &> /dev/null; then
    print_success "✅ Istio namespace exists"
    
    istiod_pods=$(kubectl get pods -n istio-system -l app=istiod -o jsonpath='{.items[*].status.phase}')
    if [[ "$istiod_pods" == *"Running"* ]]; then
        print_success "✅ Istiod is running"
    else
        print_error "❌ Istiod is not running"
    fi
    
    ingress_pods=$(kubectl get pods -n istio-system -l app=istio-ingressgateway -o jsonpath='{.items[*].status.phase}')
    if [[ "$ingress_pods" == *"Running"* ]]; then
        print_success "✅ Istio Ingress Gateway is running"
    else
        print_error "❌ Istio Ingress Gateway is not running"
    fi
else
    print_error "❌ Istio namespace does not exist"
fi
echo ""

# Check Bookinfo application
print_headline "2. Checking Bookinfo Application"
if kubectl get deployment productpage-v1 &> /dev/null; then
    print_success "✅ Bookinfo application is deployed"
    
    # Check if all pods are running
    all_pods_running=true
    for pod in $(kubectl get pods -o jsonpath='{.items[*].metadata.name}'); do
        status=$(kubectl get pod $pod -o jsonpath='{.status.phase}')
        if [ "$status" != "Running" ]; then
            all_pods_running=false
            print_error "❌ Pod $pod is not running (Status: $status)"
        fi
    done
    
    if $all_pods_running; then
        print_success "✅ All Bookinfo pods are running"
    fi
    
    # Check if sidecars are injected
    all_sidecars_injected=true
    for pod in $(kubectl get pods -o jsonpath='{.items[*].metadata.name}'); do
        containers=$(kubectl get pod $pod -o jsonpath='{.spec.containers[*].name}')
        if [[ "$containers" != *"istio-proxy"* ]]; then
            all_sidecars_injected=false
            print_error "❌ Pod $pod does not have an Istio sidecar"
        fi
    done
    
    if $all_sidecars_injected; then
        print_success "✅ All pods have Istio sidecars injected"
    fi
else
    print_error "❌ Bookinfo application is not deployed"
fi
echo ""

# Get Gateway URL
print_headline "3. Getting Gateway URL"
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$INGRESS_HOST" ]; then
    INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
fi

if [ -z "$INGRESS_HOST" ]; then
    # For minikube or environments without load balancer
    INGRESS_HOST="demo.k8s.local"
    print_info "No external load balancer found. Using demo.k8s.local"
fi

GATEWAY_URL="${INGRESS_HOST}:${INGRESS_PORT}"
print_success "Gateway URL: http://$GATEWAY_URL"
echo ""

# Test application access
print_headline "4. Testing Application Access"
test_url "http://$GATEWAY_URL/productpage" "Bookinfo Product Page"
echo ""

# Check Istio configs
print_headline "5. Checking Istio Routing Configurations"
print_info "Virtual Services:"
kubectl get virtualservices
echo ""

print_info "Destination Rules:"
kubectl get destinationrules
echo ""

print_info "Gateways:"
kubectl get gateways
echo ""

print_info "PeerAuthentication:"
kubectl get peerauthentication
echo ""

# Test traffic routing (A/B Testing)
print_headline "6. Testing Traffic Routing"
print_info "Note: In real testing, we would send traffic with different user identities"
print_info "and observe the routes to different service versions."
print_info "For the 'reviews' service:"
print_info "- User 'jason' should see reviews-v2 (with black stars)"
print_info "- Other users should see reviews-v1 (no stars)"
print_info "- With canary deployment, 10% of traffic goes to reviews-v3 (red stars)"
echo ""

# Check for Istio dashboards
print_headline "7. Checking Istio Dashboards"
print_info "To access dashboards, run the following commands:"
print_info "  istioctl dashboard kiali     # For service mesh visualization"
print_info "  istioctl dashboard grafana   # For metrics visualization"
print_info "  istioctl dashboard jaeger    # For distributed tracing"
print_info "  istioctl dashboard prometheus # For metrics collection"
print_info "Or use the dashboard.sh script for easy access"
echo ""

# Test fault injection
print_headline "8. Testing Fault Injection"
print_info "We've configured a 5-second delay for 50% of requests to the ratings service."
print_info "Visit http://$GATEWAY_URL/productpage multiple times to observe the delay."
print_info "Some page loads should take longer than others due to the delay."
echo ""

# Summary
print_headline "Test Summary"
print_success "Istio Service Mesh is set up with the Bookinfo application."
print_success "Access the application at: http://$GATEWAY_URL/productpage"
print_success "Use dashboard.sh to access monitoring tools."
echo ""
print_info "For a comprehensive test including load testing and resilience testing,"
print_info "consider using tools like hey, fortio, or Apache Benchmark (ab)."
echo ""
print_headline "Happy Service Meshing!"
echo ""
