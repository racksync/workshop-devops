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

print_headline "Cleaning up Kubernetes Container Monitoring Workshop resources"
echo ""

print_warning "This will remove all resources created for the monitoring workshop"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5
echo ""

print_info "Uninstalling Prometheus Operator Stack"
helm uninstall prometheus -n monitoring
echo ""

print_info "Removing sample application"
kubectl delete -f sample-app-with-metrics.yaml --ignore-not-found
echo ""

print_info "Removing ServiceMonitor"
kubectl delete -f service-monitor.yaml --ignore-not-found
echo ""

print_info "Removing PrometheusRule"
kubectl delete -f prometheus-rule.yaml --ignore-not-found
echo ""

print_info "Removing AlertmanagerConfig"
kubectl delete -f alertmanager-config.yaml --ignore-not-found
echo ""

print_info "Waiting for all resources to be removed from namespace..."
sleep 10
echo ""

print_info "Deleting monitoring namespace"
kubectl delete namespace monitoring
echo ""

print_info "Setting kubectl context back to default namespace"
kubectl config set-context --current --namespace=default
echo ""

print_headline "Cleanup completed successfully!"
echo ""
