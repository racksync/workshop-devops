#!/bin/bash

# Function definitions for colored output
function print_headline() {
    echo -e "\033[1;36m$1\033[0m"
    echo ""
}

function print_info() {
    echo -e "\033[0;34m$1\033[0m"
    echo ""
}

function print_success() {
    echo -e "\033[0;32m$1\033[0m"
    echo ""
}

function print_error() {
    echo -e "\033[0;31m$1\033[0m"
    echo ""
}

function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
    echo ""
}

function print_step() {
    echo -e "\033[0;35m$1\033[0m"
    echo ""
}

# Script starts here
print_headline "GitLab Kubernetes Agent Setup"

# Set directory variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/my-k8s-app"
AGENT_DIR="${PROJECT_DIR}/.gitlab/agents/my-agent"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if deployment script was run
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run deploy.sh first."
    exit 1
fi

# Prompt for GitLab project information
print_info "Please enter your GitLab project path (e.g., group/project):"
read -p "> " GITLAB_PROJECT_PATH
echo ""

# Create agent directory if it doesn't exist
mkdir -p "${AGENT_DIR}"

print_step "1. Creating GitLab Kubernetes Agent configuration file"
cat > "${AGENT_DIR}/config.yaml" << EOL
ci_access:
  projects:
    - id: ${GITLAB_PROJECT_PATH}
EOL

print_success "Agent configuration file created at: ${AGENT_DIR}/config.yaml"
echo ""

print_step "2. Instructions for registering the agent in GitLab"
print_info "Follow these steps to register your agent in GitLab:"
echo "1. Navigate to your GitLab project at: https://gitlab.com/${GITLAB_PROJECT_PATH}"
echo "2. Go to Infrastructure > Kubernetes clusters"
echo "3. Click on 'Connect a cluster' and select 'GitLab Agent'"
echo "4. Enter 'my-agent' as the agent name and click 'Create agent'"
echo "5. Follow the instructions on the screen to install the agent in your cluster"
echo ""

print_step "3. Installing the agent in your Kubernetes cluster"
print_info "Once you've registered the agent, you'll get a command like:"
echo "  helm repo add gitlab https://charts.gitlab.io"
echo "  helm repo update"
echo "  helm upgrade --install my-agent gitlab/gitlab-agent \\"
echo "    --namespace gitlab-agent-my-agent \\"
echo "    --create-namespace \\"
echo "    --set image.tag=v16.7.0 \\"
echo "    --set config.token=<your-agent-token> \\"
echo "    --set config.kasAddress=kas.gitlab.com"
echo ""

print_warning "Important: Make sure you have Helm installed before running the above commands."
echo ""

print_step "4. Testing the agent connection"
print_info "Once the agent is installed, you can verify its connection status in GitLab:"
echo "1. Go to Infrastructure > Kubernetes clusters"
echo "2. Check that your agent is connected (shown with a green indicator)"
echo ""

print_info "To test if the agent can be used in your GitLab CI pipeline:"
echo "1. Add the following to your .gitlab-ci.yml:"
echo ""
echo "deploy-with-agent:"
echo "  stage: deploy"
echo "  image: alpine:latest"
echo "  script:"
echo "    - echo \"Using GitLab Agent to deploy\""
echo "    - kubectl get pods"
echo "  variables:"
echo "    KUBE_CONTEXT: my-agent"
echo ""

print_success "GitLab Agent setup instructions provided!"
