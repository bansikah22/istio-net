# Phase 3: Infrastructure as Code

This document outlines the infrastructure setup for our project, which is managed using Terraform. This approach, known as Infrastructure as Code (IaC), allows us to define and manage our infrastructure in a declarative and version-controlled way.

## Amazon EKS Cluster

We are using Amazon Elastic Kubernetes Service (EKS) to run our containerized application. EKS is a managed Kubernetes service that simplifies the process of running Kubernetes on AWS.

### Terraform Configuration

Our Terraform configuration is located in the `infra/` directory and is broken down into the following files:

-   **`providers.tf`:** This file configures the AWS provider, which allows Terraform to interact with the AWS API.
-   **`main.tf`:** This is the main configuration file, where we define the VPC and the EKS cluster itself. We use the official `terraform-aws-modules` for both the VPC and EKS, as they provide a robust and production-ready foundation.
-   **`variables.tf`:** This file defines variables for our configuration, such as the AWS region and the cluster name. This makes our configuration more flexible and reusable.
-   **`outputs.tf`:** This file defines outputs for our configuration, such as the cluster endpoint and the CA certificate. This makes it easier to connect to the cluster after it has been created.

### How to Apply the Configuration

To create the EKS cluster, you will need to have Terraform installed and your AWS credentials configured. Then, navigate to the `infra/` directory and run the following commands:

```bash
# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply
```

This will provision the VPC, the EKS cluster, and all the necessary resources in your AWS account.
