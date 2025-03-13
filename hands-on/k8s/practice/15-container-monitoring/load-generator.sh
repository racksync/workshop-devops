#!/bin/bash

# Define color functions
function print_headline() {
  echo -e "\e[1;34m$1\e[0m"
}

function print_info() {
  echo -e "\e[0;32m$1\e[0m"
}

function print_error() {
  echo -e "\e[0;31m$1\e[0m"
}

function print_warning() {
  echo -e "\e[0;33m$1\e[0m"
}

print_headline "Load Generator for Kubernetes Container Monitoring Workshop"
echo ""

print_info "This script will generate load on the sample application to trigger alerts"
print_warning "Make sure your sample application is deployed before running this script"
echo ""
print_info "Press Enter to continue or Ctrl+C to cancel..."
read
echo ""

# Create a load generator deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-generator
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-generator
  template:
    metadata:
      labels:
        app: load-generator
    spec:
      containers:
      - name: load-generator
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            for i in \$(seq 1 100); do
              wget -q -O- http://sample-app > /dev/null || true
              sleep 0.1
            done
            echo "Generated 100 requests"
            sleep 2
          done
EOF

print_info "Load generator deployment created"
echo ""

print_info "Waiting for load-generator pod to be ready..."
kubectl wait --for=condition=ready pod -l app=load-generator -n monitoring --timeout=60s
echo ""

print_headline "Load generator is now running"
echo ""

print_info "You can check the load generator logs with:"
echo "kubectl logs -f deployment/load-generator -n monitoring"
echo ""

print_info "To stop the load generator, run:"
echo "kubectl delete deployment load-generator -n monitoring"
echo ""

print_info "To increase CPU load on the sample app (to trigger alerts), run:"
echo "kubectl scale deployment load-generator --replicas=3 -n monitoring"
echo ""

print_warning "Remember to check the Prometheus alerts and Grafana dashboards to see the effect"
echo "Check the alerts at http://localhost:9090/alerts after running test.sh"
echo ""
