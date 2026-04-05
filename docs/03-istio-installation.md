# Phase 4: Istio Installation

This document details the installation of Istio into our EKS cluster. We use a combination of Terraform and Helm to manage the Istio installation, which allows for an automated and version-controlled setup.

## Installation Method

We use the official Istio Helm charts to install the various components of the service mesh. The Helm charts are managed declaratively through Terraform using the `hashicorp/helm` provider.

### Terraform Configuration

The Terraform configuration for the Istio installation is located in the `infra/istio.tf` file. It is responsible for installing the following core Istio components in the `istio-system` namespace:

1.  **`istio-base`:** This chart installs the basic Custom Resource Definitions (CRDs) that are required for the other Istio components to function correctly.
2.  **`istiod`:** This chart installs the main Istio control plane component, `istiod`. It is responsible for service discovery, configuration, and certificate management.
3.  **`istio-ingress`:** This chart installs the Istio ingress gateway. This component provides an entry point for external traffic into the service mesh, allowing us to expose our services to the internet.

### Applying the Configuration

The Istio installation is part of the main Terraform configuration in the `infra/` directory. To install or update Istio, you simply need to run the standard Terraform commands from that directory:

```bash
# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply
```

This will install or update the Istio components in the EKS cluster alongside the rest of our infrastructure.
