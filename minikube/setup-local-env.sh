#!/bin/bash

# This script automates the setup of the local development environment.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Determine Project Root ---
# This allows the script to be run from any directory within the project.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( dirname "$SCRIPT_DIR" )

# --- Configuration ---
REQUIRED_K8S_VERSION="v1.30.0"
ISTIO_VERSION="1.29.1"
HELM_RELEASE_NAME="prime-calculator"
CHART_DIR="${PROJECT_ROOT}/charts/prime-calculator"

# --- Prerequisite Check: Verify Minikube is installed ---
if ! command -v minikube &> /dev/null; then
    echo "❌ Error: minikube command not found."
    echo "Please install Minikube before running this script."
    echo "Installation guide: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi
echo "✅ Minikube is installed."

# --- Step 1: Ensure Minikube is running with a compatible Kubernetes version ---
echo "ℹ️  Checking Minikube status and Kubernetes version..."

start_minikube() {
  echo "⏳ Starting Minikube with Kubernetes ${REQUIRED_K8S_VERSION}..."
  minikube start --kubernetes-version=${REQUIRED_K8S_VERSION} --cpus 4 --memory 8192
  if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to start Minikube. Please check your Minikube installation."
    exit 1
  fi
  echo "✅ Minikube started successfully."
}

if minikube status &> /dev/null; then
  echo "✅ Minikube cluster is already running."
  # Use a compatible kubectl version command
  CURRENT_K8S_VERSION=$(kubectl version | grep 'Server Version:' | awk '{print $3}')
  echo "ℹ️  Detected Kubernetes version: ${CURRENT_K8S_VERSION}."
  echo "ℹ️  Required Kubernetes version: ${REQUIRED_K8S_VERSION}."

  if [ "${CURRENT_K8S_VERSION}" != "${REQUIRED_K8S_VERSION}" ]; then
    echo "⚠️  Warning: Incorrect Kubernetes version found."
    echo "The existing Minikube cluster will be deleted and recreated to ensure compatibility."
    
    echo "⏳ Stopping and deleting the current Minikube cluster..."
    minikube stop > /dev/null
    minikube delete > /dev/null
    
    start_minikube
  else
    echo "✅ Kubernetes version is compatible. Skipping cluster creation."
  fi
else
  echo "ℹ️  Minikube is not running."
  start_minikube
fi

# --- Step 2: Configure istioctl ---
ISTIO_DIR="$HOME/istio-${ISTIO_VERSION}"
if [ -d "$ISTIO_DIR" ]; then
  export PATH="$PATH:$ISTIO_DIR/bin"
  echo "✅ istioctl added to PATH for this session."
else
  echo "❌ Error: Istio directory not found at $ISTIO_DIR"
  echo "Please download Istio by running: curl -L https://istio.io/downloadIstio | sh -"
  exit 1
fi

# --- Step 3: Install Istio ---
echo "⏳ Installing Istio with the 'demo' profile..."
istioctl install --set profile=demo -y
echo "✅ Istio installation complete."

# --- Step 4: Install Istio Observability Addons (Prometheus & Kiali) ---
echo "⏳ Installing Prometheus and Kiali addons..."
# We use the raw github URLs to ensure we get the manifests matching our ISTIO_VERSION
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.29/samples/addons/prometheus.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.29/samples/addons/kiali.yaml"
# Apply the ingress configurations
kubectl apply -f "${PROJECT_ROOT}/minikube/kiali-ingress.yaml"
kubectl apply -f "${PROJECT_ROOT}/minikube/prometheus-ingress.yaml"
# Apply the strict mTLS policy
kubectl apply -f "${PROJECT_ROOT}/minikube/mtls-policy.yaml"

echo "✅ Istio observability addons installation started."

# --- Step 5: Create Image Pull Secret ---
# IMPORTANT: Replace the placeholders with your actual GitHub credentials.
# You can create a Personal Access Token (PAT) here: https://github.com/settings/tokens/new
# The PAT only needs the `read:packages` scope.
GITHUB_USERNAME="<your-github-username>" # Replace with your GitHub username
GITHUB_PAT="<your-personal-access-token>"

if [ "$GITHUB_USERNAME" == "<your-github-username>" ] || [ "$GITHUB_PAT" == "<your-personal-access-token>" ]; then
  echo "❌ Error: Please edit the setup-local-env.sh script and replace the placeholder GitHub credentials."
  exit 1
fi

echo "⏳ Creating the image pull secret 'ghcr-credentials'..."
# Delete the secret if it already exists to ensure it's up-to-date
kubectl delete secret docker-registry ghcr-credentials > /dev/null 2>&1 || true
kubectl create secret docker-registry ghcr-credentials \
  --docker-server=ghcr.io \
  --docker-username="$GITHUB_USERNAME" \
  --docker-password="$GITHUB_PAT"
echo "✅ Image pull secret created."

# --- Step 6: Deploy Application ---
echo "⏳ Deploying the application using Helm..."
helm uninstall ${HELM_RELEASE_NAME} > /dev/null 2>&1 || true
# The chart now defaults to the correct stable image from ghcr.io.
# We just need to enable Istio integration for the setup.
helm install ${HELM_RELEASE_NAME} "${CHART_DIR}" --set istio.enabled=true
echo "✅ Application deployment complete."

# --- Final Instructions ---
echo "--------------------------------------------------"
echo "🚀 Local Environment Setup Complete!"
echo ""
echo "Next Steps:"
echo "1. Open a NEW terminal window."
echo "2. Run the following command to expose the Istio Ingress Gateway:"
echo "   minikube tunnel"
echo ""
echo "3. Once the tunnel is active, access your services at the following URLs:"
GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "   - Prime Calculator App: http://app.${GATEWAY_IP}.nip.io"
echo "   - Kiali Dashboard:      http://kiali.${GATEWAY_IP}.nip.io"
echo "   - Prometheus UI:        http://prometheus.${GATEWAY_IP}.nip.io"
echo ""
echo "   (Note: The 'minikube tunnel' command must be running in another terminal.)"
echo "--------------------------------------------------"
echo "--------------------------------------------------"
