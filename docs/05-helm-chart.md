# Phase 5: Application Deployment with Helm

This document details the structure and usage of the Helm chart created for deploying the Prime Calculator application onto a Kubernetes cluster.

## What is Helm?

Helm is a package manager for Kubernetes. It helps you define, install, and upgrade even the most complex Kubernetes applications. Helm charts are packages of pre-configured Kubernetes resources.

## Chart Structure

The Helm chart for our application is located in the `charts/prime-calculator` directory and has the following structure:

```
charts/
└── prime-calculator/
    ├── Chart.yaml          # Metadata about the chart (name, version, etc.)
    ├── values.yaml         # Default configuration values for the chart
    └── templates/          # Directory for the Kubernetes manifest templates
        ├── _helpers.tpl    # Template helpers for reuse within the chart
        ├── deployment.yaml # Template for the Kubernetes Deployment
        ├── service.yaml    # Template for the Kubernetes Service
        ├── ingress.yaml    # Template for the Kubernetes Ingress
        ├── hpa.yaml        # Template for the HorizontalPodAutoscaler
        └── serviceaccount.yaml # Template for the ServiceAccount
```

### Key Files

-   **`Chart.yaml`**: Contains metadata about the chart, such as its name, version, and a description.
-   **`values.yaml`**: This is the main configuration file for the chart. It allows you to customize the deployment without modifying the core templates. You can override these values when you install the chart. Key configurable values include the image repository and tag, replica count, and service port.
-   **`templates/`**: This directory holds the template files that are processed by Helm to generate the final Kubernetes manifests.
    -   **`deployment.yaml`**: Defines the `Deployment` resource, which manages the application's pods. It specifies the container image to use, the number of replicas, and other pod-related settings.
    -   **`service.yaml`**: Defines the `Service` resource, which provides a stable network endpoint (a ClusterIP) to access the application pods within the cluster.
    -   **`ingress.yaml`**: (Optional) Defines an `Ingress` resource to expose the application to traffic from outside the cluster. This is disabled by default.
    -   **`hpa.yaml`**: (Optional) Defines a `HorizontalPodAutoscaler` to automatically scale the number of application pods based on CPU or memory usage. This is disabled by default.

## How to Use the Chart

To deploy the application using this Helm chart, you would typically use the `helm install` command from your terminal, pointing to the chart's directory.

```sh
# Example of installing the chart
helm install my-release ./charts/prime-calculator \
  --set image.tag=v2.0.0-stable
```

This command would deploy a new release named `my-release` using the `prime-calculator` chart and override the default image tag to use `v2.0.0-stable`.

## Accessing the Application

By default, the chart creates a `ClusterIP` service, which is only accessible from within the Kubernetes cluster. To access the application from your local machine, you can use `kubectl port-forward`.

1.  **Get the name of the pod:**

    ```sh
    kubectl get pods -l app.kubernetes.io/name=prime-calculator
    ```

2.  **Forward a local port to the pod's port:**

    Replace `POD_NAME` with the name of the pod from the previous command.

    ```sh
    kubectl port-forward POD_NAME 8080:3001
    ```

Now you can access the application by navigating to `http://localhost:8080` in your web browser.
