# Istio Canary Deployment Demo

This project is a hands-on demonstration of canary releases using Istio on a Kubernetes cluster. It features a simple "Prime Calculator" web application, a Helm chart for deployment, and a fully automated local setup script for Minikube.

The primary goal is to provide a practical, working example of how to leverage Istio's traffic management capabilities to safely roll out new versions of an application.

## Getting Started

A shell script is provided to automate the entire setup of a local development environment using Minikube.

### Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)

### Automated Setup

The setup script will:
1.  Ensure Minikube is running with a compatible version of Kubernetes.
2.  Install Istio.
3.  Create the necessary image pull secrets.
4.  Deploy the application using the provided Helm chart.

To run the script, execute the following command from the root of the project:

```bash
./minikube/setup-local-env.sh
```

After the script completes, it will provide you with the final instructions to access the application through the Istio Ingress Gateway.

## Project Structure

-   **/app**: Contains the Node.js source code for the simple web application.
-   **/charts**: Contains the Helm chart used to deploy the application and its associated Kubernetes and Istio resources.
-   **/docs**: Contains project documentation and images.
-   **/infra**: Contains Terraform code for provisioning cloud infrastructure (not used in the local setup).
-   **/minikube**: Contains the automated setup script for the local Minikube environment.

## Key Features

-   **Automated Local Setup:** Get a fully configured local environment running with a single command.
-   **Istio Integration:** Demonstrates the use of Istio's `Gateway`, `VirtualService`, and `DestinationRule` for traffic management.
-   **Canary Releases:** The Helm chart is pre-configured to support canary releases, allowing you to safely test new versions of the application with a subset of traffic.
