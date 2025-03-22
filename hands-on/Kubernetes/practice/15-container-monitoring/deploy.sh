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

# Main deployment script
print_headline "Starting Kubernetes Container Monitoring Workshop deployment"
echo ""

print_info "Creating monitoring namespace"
kubectl create namespace monitoring
echo ""

print_info "Setting kubectl context to the monitoring namespace"
kubectl config set-context --current --namespace=monitoring
echo ""

print_info "Adding Prometheus Community Helm repository"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo ""

print_info "Installing Prometheus Operator Stack with Helm"
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f values.yaml
echo ""

print_info "Waiting for Prometheus components to be ready..."
kubectl wait --for=condition=ready pod -l app=prometheus --timeout=300s
echo ""

print_info "Deploying sample app with metrics"
kubectl apply -f sample-app-with-metrics.yaml
echo ""

print_info "Configuring ServiceMonitor for the sample app"
kubectl apply -f service-monitor.yaml
echo ""

print_info "Creating Prometheus alerting rules"
kubectl apply -f prometheus-rule.yaml
echo ""

print_info "Configuring Alertmanager"
kubectl apply -f alertmanager-config.yaml
echo ""

print_headline "Deployment completed successfully!"
echo ""

print_info "To access Grafana:"
echo "kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
echo "Then open http://localhost:3000 in your browser"
echo "Username: admin"
echo "Password: admin123"
echo ""

print_info "To access Prometheus:"
echo "kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring"
echo "Then open http://localhost:9090 in your browser"
echo ""

print_info "To access Alertmanager:"
echo "kubectl port-forward svc/alertmanager-operated 9093:9093 -n monitoring"
echo "Then open http://localhost:9093 in your browser"
echo ""

print_warning "Remember to add demo.k8s.local to your /etc/hosts file if you want to use this hostname"
echo "127.0.0.1 demo.k8s.local"
echo ""
