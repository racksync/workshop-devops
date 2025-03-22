#!/bin/bash

# Function to display colored text
function print_color() {
    local color=$1
    local text=$2
    
    case $color in
        "info") echo -e "\033[0;36m${text}\033[0m" ;; # Cyan
        "success") echo -e "\033[0;32m${text}\033[0m" ;; # Green
        "error") echo -e "\033[0;31m${text}\033[0m" ;; # Red
        "warning") echo -e "\033[0;33m${text}\033[0m" ;; # Yellow
        "headline") echo -e "\033[1;34m${text}\033[0m" ;; # Blue bold
        *) echo "$text" ;;
    esac
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_color "error" "kubectl could not be found. Please install kubectl first."
    exit 1
fi

# Check if pod-patterns namespace exists
if ! kubectl get namespace pod-patterns &> /dev/null; then
    print_color "error" "The pod-patterns namespace doesn't exist. Please run ./deploy.sh first."
    exit 1
fi

print_color "headline" "Testing Kubernetes Multi-Container Pod Patterns"

# Set namespace for this session
kubectl config set-context --current --namespace=pod-patterns

echo ""
print_color "headline" "1. Testing Sidecar Pattern"
print_color "info" "Checking if sidecar-pattern pod is running"

if kubectl get pod sidecar-pattern -o jsonpath="{.status.phase}" | grep -q "Running"; then
    print_color "success" "Sidecar pattern pod is running"
    
    echo ""
    print_color "info" "Output from log-sidecar container (should show application logs):"
    echo ""
    kubectl logs sidecar-pattern -c log-sidecar | tail -5
else
    print_color "error" "Sidecar pattern pod is not running"
fi

echo ""
print_color "headline" "2. Testing Ambassador Pattern"
print_color "info" "Checking if ambassador-pattern pod is running"

if kubectl get pod ambassador-pattern -o jsonpath="{.status.phase}" | grep -q "Running"; then
    print_color "success" "Ambassador pattern pod is running"
    
    echo ""
    print_color "info" "Output from app container (should show responses from the ambassador):"
    echo ""
    kubectl logs ambassador-pattern -c app | tail -10
else
    print_color "error" "Ambassador pattern pod is not running"
fi

echo ""
print_color "headline" "3. Testing Adapter Pattern"
print_color "info" "Checking if adapter-pattern pod is running"

if kubectl get pod adapter-pattern -o jsonpath="{.status.phase}" | grep -q "Running"; then
    print_color "success" "Adapter pattern pod is running"
    
    echo ""
    print_color "info" "Original logs from app container:"
    echo ""
    kubectl exec adapter-pattern -c app -- tail -5 /var/log/app.log
    
    echo ""
    print_color "info" "Transformed logs from adapter container (should only show ERROR logs with modified format):"
    echo ""
    kubectl exec adapter-pattern -c log-adapter -- cat /var/transformed/error.log | tail -5
else
    print_color "error" "Adapter pattern pod is not running"
fi

echo ""
print_color "headline" "4. Testing Init Container"
print_color "info" "Checking if init-container-demo pod is running"

if kubectl get pod init-container-demo -o jsonpath="{.status.phase}" | grep -q "Running"; then
    print_color "success" "Init container demo pod is running"
    
    echo ""
    print_color "info" "Output from init container:"
    echo ""
    kubectl logs init-container-demo -c init-db
    
    echo ""
    print_color "info" "Output from main container (should show it found the initialization script):"
    echo ""
    kubectl logs init-container-demo -c app | head -10
else
    print_color "error" "Init container demo pod is not running"
fi

echo ""
print_color "headline" "5. Testing Web Application with Monitoring Sidecar"
print_color "info" "Checking if web-app pods are running"

if kubectl get pods -l app=web-app | grep -q "Running"; then
    print_color "success" "Web application pods are running"
    
    print_color "info" "Starting port-forward to access the web application"
    print_color "info" "Please open http://localhost:8080 in your browser"
    print_color "info" "Press Ctrl+C to stop port-forwarding when done"
    
    echo ""
    print_color "info" "Current metrics (before accessing the web app):"
    kubectl exec $(kubectl get pod -l app=web-app -o jsonpath="{.items[0].metadata.name}") -c metrics-exporter -- cat /metrics/requests.prom
    
    echo ""
    print_color "warning" "Starting port-forward to web-app service on port 8080..."
    kubectl port-forward service/web-app 8080:80 &
    PF_PID=$!
    
    # Wait for a moment to allow the port-forward to establish
    sleep 5
    
    # Generate some traffic
    print_color "info" "Generating some test traffic to the web app..."
    curl -s http://localhost:8080 > /dev/null
    curl -s http://localhost:8080 > /dev/null
    curl -s http://localhost:8080 > /dev/null
    
    # Wait for the metrics to update
    sleep 20
    
    echo ""
    print_color "info" "Updated metrics (after accessing the web app):"
    kubectl exec $(kubectl get pod -l app=web-app -o jsonpath="{.items[0].metadata.name}") -c metrics-exporter -- cat /metrics/requests.prom
    
    # Kill the port-forward process
    kill $PF_PID 2>/dev/null
    wait $PF_PID 2>/dev/null
else
    print_color "error" "Web application pods are not running"
fi

echo ""
print_color "headline" "Testing Summary"
echo ""
print_color "info" "All pod patterns have been tested"
print_color "info" "To clean up all resources, run: ./cleanup.sh"

# If you wish to add hostnames to your /etc/hosts file
echo ""
print_color "warning" "Note: For a complete setup in a production environment"
print_color "info" "You might want to add the following entry to your /etc/hosts file:"
print_color "info" "127.0.0.1    demo.k8s.local"
