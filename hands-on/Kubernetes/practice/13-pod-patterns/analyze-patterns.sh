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

# Set namespace for this session
kubectl config set-context --current --namespace=pod-patterns

print_color "headline" "Multi-Container Pod Patterns Analysis"
echo ""

print_color "headline" "Pod Resource Usage Analysis"
echo ""
print_color "info" "Checking resource usage across all pods"
kubectl top pods 2>/dev/null || print_color "warning" "Could not get resource usage. Make sure metrics-server is installed."

echo ""
print_color "headline" "Container Communication Analysis"

echo ""
print_color "info" "1. Sidecar Pattern - Shared Volume Analysis:"
kubectl exec sidecar-pattern -c app -- ls -la /var/log/
echo ""
kubectl exec sidecar-pattern -c log-sidecar -- ls -la /var/log/

echo ""
print_color "info" "2. Ambassador Pattern - Network Communication Analysis:"
kubectl exec ambassador-pattern -c app -- netstat -tulpn 2>/dev/null || \
  print_color "warning" "netstat not available, using alternative"
echo ""
kubectl exec ambassador-pattern -c app -- wget -q -O- http://localhost:9000

echo ""
print_color "info" "3. Adapter Pattern - Data Transformation Analysis:"
# Get original logs format
echo "Original log format:"
kubectl exec adapter-pattern -c app -- tail -2 /var/log/app.log
echo ""
# Get transformed logs format
echo "Transformed log format:"
kubectl exec adapter-pattern -c log-adapter -- cat /var/transformed/error.log | tail -2

echo ""
print_color "headline" "Multi-Container Pod Design Patterns Comparison"
echo ""
print_color "info" "1. Sidecar Pattern:"
echo "  - Primary function: Extend and enhance the main container"
echo "  - Communication: Via shared volume"
echo "  - Use case: Logging, monitoring, syncing"
echo ""

print_color "info" "2. Ambassador Pattern:"
echo "  - Primary function: Proxy communication to the outside world"
echo "  - Communication: Via localhost network" 
echo "  - Use case: Service discovery, connection pooling"
echo ""

print_color "info" "3. Adapter Pattern:"
echo "  - Primary function: Standardize output from the main container"
echo "  - Communication: Via shared volume"
echo "  - Use case: Log formatting, protocol conversion"
echo ""

print_color "info" "4. Init Container Pattern:"
echo "  - Primary function: Run before application containers start"
echo "  - Communication: Via shared volume"
echo "  - Use case: Setup, database migration, dependency checks"

echo ""
print_color "headline" "Networking & Inter-Container Communication Test"

# Get one of the web-app pods
WEB_POD=$(kubectl get pod -l app=web-app -o jsonpath="{.items[0].metadata.name}")

if [ -n "$WEB_POD" ]; then
    echo ""
    print_color "info" "Testing inter-container communication in $WEB_POD"
    
    echo ""
    print_color "info" "Network interfaces in the pod:"
    kubectl exec $WEB_POD -c web -- ip addr 2>/dev/null || \
      print_color "warning" "ip command not available"
    
    echo ""
    print_color "info" "Port listening in the web container:"
    kubectl exec $WEB_POD -c web -- netstat -tulpn 2>/dev/null || \
      print_color "warning" "netstat not available"
      
    echo ""
    print_color "info" "Testing localhost access between containers:"
    kubectl exec $WEB_POD -c metrics-exporter -- wget -q -O- http://localhost 2>/dev/null && \
      print_color "success" "Localhost communication between containers works!" || \
      print_color "error" "Localhost communication between containers failed!"
else
    print_color "error" "No web-app pods found"
fi

echo ""
print_color "headline" "Volume Sharing Analysis"

print_color "info" "Checking shared volumes in each pattern:"

echo ""
print_color "info" "1. Sidecar Pattern - shared log volume:"
kubectl exec sidecar-pattern -c app -- du -sh /var/log/
kubectl exec sidecar-pattern -c log-sidecar -- du -sh /var/log/

echo ""
print_color "info" "2. Adapter Pattern - shared & transformed volumes:"
kubectl exec adapter-pattern -c app -- du -sh /var/log/
kubectl exec adapter-pattern -c log-adapter -- du -sh /var/log/
kubectl exec adapter-pattern -c log-adapter -- du -sh /var/transformed/

echo ""
print_color "info" "3. Init Container - shared init data:"
kubectl exec init-container-demo -c app -- ls -la /init-data/
kubectl exec init-container-demo -c app -- cat /init-data/init.sql

echo ""
print_color "success" "Analysis complete!"
print_color "info" "This analysis helps visualize how different multi-container pod patterns work in practice"
print_color "info" "To clean up all resources, run: ./cleanup.sh"
