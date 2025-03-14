#!/bin/bash

# Color function definitions
function print_info() { echo -e "\033[0;34m${1}\033[0m"; }
function print_success() { echo -e "\033[0;32m${1}\033[0m"; }
function print_error() { echo -e "\033[0;31m${1}\033[0m"; }
function print_headline() { echo -e "\033[1;33m${1}\033[0m"; }

print_headline "Cleaning up resources"

# Delete namespace
kubectl delete namespace python-demo

echo ""

# Remove Docker image
docker rmi python-app:latest

echo ""

print_success "Cleanup completed successfully"
