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
-   **`istio.tf`:** This file contains the Helm release definitions for installing the core Istio components (`istio-base`, `istiod`, and the `istio-ingress` gateway) into our cluster.

### Node Group Configuration

The EKS cluster is configured with a single managed node group named `node-group-1`. Here are the key details:

-   **Instance Type**: The nodes are `t3.medium` instances, which provide a good balance of compute, memory, and network resources for our application.
-   **Scaling**: The node group is configured to autoscale between a minimum of 1 and a maximum of 3 nodes, with a desired count of 2 nodes. This allows the cluster to handle varying loads while maintaining cost-efficiency.
-   **Networking**: The nodes are provisioned in the **private subnets** of our VPC. This is a critical security measure that ensures our worker nodes are not directly exposed to the public internet. They can initiate outbound connections through the NAT Gateway, but incoming traffic must be routed through a load balancer or ingress controller.

### Istio Installation via Terraform

The `istio.tf` file automates the installation of Istio's core components using the official Istio Helm charts. This is a declarative approach that ensures a consistent and repeatable Istio installation.

-   **`istio-base`**: This chart installs the foundational Custom Resource Definitions (CRDs) that are required by Istio.
-   **`istiod`**: This chart installs the `istiod` deployment, which is the core of the Istio control plane. It is responsible for service discovery, configuration, and certificate management.
-   **`istio-ingress`**: This chart installs the Istio Ingress Gateway, which is an Envoy-based proxy that manages incoming traffic to the service mesh.

By managing the Istio installation with Terraform, we can ensure that it is tightly integrated with our EKS cluster and that its lifecycle is managed alongside the rest of our infrastructure.

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

## Connecting to the Cluster

Once the `terraform apply` command has completed successfully, the EKS cluster will be running. To interact with it using `kubectl`, you need to update your local kubeconfig file.

1.  **Update Kubeconfig:**

    Run the following AWS CLI command to automatically configure `kubectl`. You will need to replace `<aws-region>` and `<cluster-name>` with the values you used in your `terraform.tfvars` file (or the defaults in `variables.tf`).

    ```bash
    aws eks update-kubeconfig --region <aws-region> --name <cluster-name>
    ```

    For example, if you used the default variable values:
    ```bash
    aws eks update-kubeconfig --region us-east-1 --name istio-eks-cluster
    ```

2.  **Verify Connection:**

    After updating your kubeconfig, you can verify that you can connect to the cluster by listing the worker nodes.

    ```bash
    kubectl get nodes
    ```

    You should see an output listing the nodes that were provisioned by Terraform, similar to this:

    ```
    NAME                                           STATUS   ROLES    AGE   VERSION
    ip-10-0-1-123.us-east-1.compute.internal   Ready    <none>   15m   v1.34.0-eks-abcde
    ip-10-0-2-45.us-east-1.compute.internal    Ready    <none>   15m   v1.34.0-eks-abcde
    ```
