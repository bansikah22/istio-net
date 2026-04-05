# Infrastructure as Code (IaC)

This directory contains all the Terraform code required to provision the cloud infrastructure for the Istio learning project.

## Structure

- `main.tf`: Defines the core AWS resources, including the VPC and the EKS cluster, using official Terraform modules.
- `variables.tf`: Contains variable definitions for customizing the infrastructure (e.g., cluster name, AWS region).
- `outputs.tf`: Defines the output values from our infrastructure, such as the EKS cluster endpoint.
- `providers.tf`: Configures the Terraform providers for AWS, Kubernetes, and Helm.
- `istio.tf`: Contains the Helm release definitions for installing Istio components (`istio-base`, `istiod`, `istio-ingress`).

## Usage

To apply this configuration, you will need to have Terraform installed and your AWS credentials configured.

1. **Initialize Terraform:**
   ```sh
   terraform init
   ```

2. **Plan the deployment:**
   ```sh
   terraform plan
   ```

3. **Apply the configuration:**
   ```sh
   terraform apply
   ```
