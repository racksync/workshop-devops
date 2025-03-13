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

print_headline "Testing Kubernetes Container Monitoring Workshop setup"
echo ""

print_info "Checking if monitoring namespace exists"
if kubectl get namespace monitoring &> /dev/null; then
  print_info "Monitoring namespace found"
else
  print_error "Monitoring namespace not found. Please run deploy.sh first."
  exit 1
fi
echo ""

print_info "Checking Prometheus Operator deployment"
if kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus-operator | grep Running &> /dev/null; then
  print_info "Prometheus Operator is running"
else
  print_error "Prometheus Operator is not running. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_info "Checking Prometheus StatefulSet"
if kubectl get pods -n monitoring -l app=prometheus | grep Running &> /dev/null; then
  print_info "Prometheus is running"
else
  print_error "Prometheus is not running. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_info "Checking Grafana deployment"
if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana | grep Running &> /dev/null; then
  print_info "Grafana is running"
else
  print_error "Grafana is not running. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_info "Checking sample application deployment"
if kubectl get pods -n monitoring -l app=sample-app | grep Running &> /dev/null; then
  print_info "Sample application is running"
else
  print_error "Sample application is not running. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_info "Checking ServiceMonitor configuration"
if kubectl get servicemonitor -n monitoring sample-app &> /dev/null; then
  print_info "ServiceMonitor is configured"
else
  print_error "ServiceMonitor is not configured. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_info "Checking PrometheusRule configuration"
if kubectl get prometheusrule -n monitoring sample-app-alerts &> /dev/null; then
  print_info "PrometheusRule is configured"
else
  print_error "PrometheusRule is not configured. Something went wrong with the deployment."
  exit 1
fi
echo ""

print_headline "Starting port-forwarding for testing"
echo ""

print_info "Port-forwarding Prometheus UI to localhost:9090"
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring &
PROMETHEUS_PID=$!
echo ""

print_info "Port-forwarding Grafana to localhost:3000"
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring &
GRAFANA_PID=$!
echo ""

print_info "Port-forwarding sample application to localhost:8080"
kubectl port-forward svc/sample-app 8080:80 -n monitoring &
SAMPLE_APP_PID=$!
echo ""

print_headline "All services are forwarded to localhost ports:"
echo "- Prometheus: http://localhost:9090 or http://demo.k8s.local:9090"
echo "- Grafana: http://localhost:3000 or http://demo.k8s.local:3000"
echo "  Username: admin"
echo "  Password: admin123"
echo "- Sample App: http://localhost:8080 or http://demo.k8s.local:8080"
echo ""

print_warning "Remember to add demo.k8s.local to your /etc/hosts file:"
echo "127.0.0.1 demo.k8s.local"
echo ""

print_headline "Press Enter to stop port-forwarding and exit..."
read

print_info "Stopping port-forwarding processes"
kill $PROMETHEUS_PID $GRAFANA_PID $SAMPLE_APP_PID
echo ""

print_headline "Test completed!"
echo ""
