# Prime Calculator Helm Chart

This chart bootstraps a deployment of the Prime Calculator application on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release .
```

The command deploys the application on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Deploying to Minikube with Istio

For local development, you can deploy the chart to a Minikube cluster with Istio enabled. This will create the necessary `Gateway` and `VirtualService` resources to expose the application.

1.  **Build the local image:**
    Before deploying, you must build your Docker image and load it into the Minikube cluster's internal registry.

    ```console
    # Point your local Docker client to Minikube's Docker daemon
    eval $(minikube -p minikube docker-env)

    # Build the image from the 'app' directory
    docker build -t prime-calculator:v1 ./app
    ```

2.  **Install the chart with Istio enabled:**
    Use the following command to install the chart. This command overrides the default image repository to use your local build and enables the Istio integration.

    ```console
    helm install my-release . \
      --set image.repository=prime-calculator \
      --set image.tag=v1 \
      --set istio.enabled=true
    ```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Prime Calculator chart and their default values.

| Parameter                  | Description                                     | Default                                           |
| -------------------------- | ----------------------------------------------- | ------------------------------------------------- |
| `replicaCount`             | Number of replicas to deploy                    | `1`                                               |
| `image.repository`         | Image repository                                | `ghcr.io/bansikah22/istio-net/istio-test-app`       |
| `image.pullPolicy`         | Image pull policy                               | `IfNotPresent`                                    |
| `image.tag`                | Image tag (overrides the chart's appVersion)    | `""`                                              |
| `service.type`             | Kubernetes service type                         | `ClusterIP`                                       |
| `service.port`             | Kubernetes service port                         | `80`                                              |
| `ingress.enabled`          | Enable ingress controller resource              | `false`                                           |
| `autoscaling.enabled`      | Enable horizontal pod autoscaling               | `false`                                           |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release . --set replicaCount=2
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install my-release . -f values.yaml
```
