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

## Accessing the Application

Once the application is deployed and running, you can access it through the Istio Ingress Gateway.

1.  **Start the Minikube Tunnel**

    If it's not already running, open a new terminal and run:

    ```console
    minikube tunnel
    ```
    This command creates a network route to the services running inside Minikube and needs to be kept running in its own terminal.

2.  **Get the External IP Address**

    In another terminal, find the external IP address of the Istio Ingress Gateway with the following command:

    ```console
    kubectl get svc istio-ingressgateway -n istio-system
    ```

    Look for the value in the `EXTERNAL-IP` column. You can then access the application by navigating to `http://<EXTERNAL-IP>` in your browser.

## Canary Releases with Istio

This chart supports canary releases using Istio for traffic splitting. When you enable the canary deployment, the chart will:

1.  Deploy a second "canary" version of the application using the image tag specified in `canary.tag`.
2.  Create an Istio `DestinationRule` to define `stable` and `canary` subsets.
3.  Create an Istio `VirtualService` to split traffic between the two subsets. By default, it sends 10% of traffic to the canary and 90% to stable.

### Enabling the Canary Release

To enable the canary release, upgrade your Helm deployment with the following command. This command assumes you have already installed the chart with a release name like `my-release`.

```console
helm upgrade my-release . \
  --set canary.enabled=true \
  --set canary.tag=v2.0.0-canary \
  --set istio.enabled=true
```

This will deploy the `v2.0.0-canary` version alongside the stable version and automatically start splitting traffic.

### Disabling the Canary Release

To disable the canary and route all traffic back to the stable version, simply run:

```console
helm upgrade my-release . --set canary.enabled=false
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

## Istio Sidecar Injection

For your application to be part of the Istio service mesh, it must have the Istio sidecar proxy injected into its pod. This sidecar is what allows Istio to manage, secure, and monitor the traffic to and from your application. Without it, your application is invisible to the service mesh.

There are two primary ways to enable sidecar injection:

1.  **Automatic Namespace Injection (Recommended):** This is the most common method. You apply a label to the Kubernetes namespace where your application is deployed, and Istio will automatically inject the sidecar into every pod created in that namespace.

    ```console
    kubectl label namespace <your-namespace> istio-injection=enabled --overwrite
    ```

2.  **Manual Pod Annotation:** You can control injection on a per-deployment basis by adding an annotation to your pod's metadata in the `deployment.yaml` file. This provides more granular control and is useful when you don't want to inject the sidecar into every pod in a namespace.

    ```yaml
    spec:
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "true"
    ```
    This Helm chart includes this annotation in the `deployment.yaml`, commented out by default, as a best practice.

## Troubleshooting

This chart and application have been through a comprehensive debugging process. Here are the key issues that were identified and resolved:

1.  **ImagePullBackOff Error**: The initial deployment failed because Kubernetes could not pull the private container image. This was resolved by correcting the `imagePullSecrets` path in the `deployment.yaml` to point to the correct location in the `values.yaml` file.

2.  **CrashLoopBackOff (EJS Template Error)**: The application would crash immediately on startup. By manually running the application inside the container, we discovered a `ReferenceError` in the `index.ejs` template. This was fixed by ensuring the `error` variable was always passed during rendering in `index.js`.

3.  **CrashLoopBackOff (Process Exiting)**: Even after fixing the template, the application would start and then exit with a `Completed` status, causing Kubernetes to restart it. This was a subtle Node.js event loop issue. The workaround was to add a `setInterval` function to `index.js` to ensure the process never runs out of tasks and stays alive.

4.  **Deployment Not Updating**: Code changes were not being reflected in the running pods. This was because the `imagePullPolicy` was set to `IfNotPresent`, and Kubernetes was using a cached, outdated version of the image. Changing the `imagePullPolicy` to `Always` in `values.yaml` forced Kubernetes to pull the latest image on every deployment.

5.  **"No Healthy Upstream" (Istio Error)**: After the pod was running, Istio was still unable to route traffic to it. This was caused by overly aggressive liveness and readiness probes that were failing before the application was fully started. The final solution was to remove the probes from the `deployment.yaml` to ensure the application could start and accept traffic without being terminated by Kubernetes.

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Prime Calculator chart and their default values.

| Parameter                  | Description                                     | Default                                           |
| -------------------------- | ----------------------------------------------- | ------------------------------------------------- |
| `replicaCount`             | Number of replicas to deploy                    | `1`                                               |
| `image.repository`         | Image repository                                | `ghcr.io/bansikah22/istio-net/istio-test-app`       |
| `image.pullPolicy`         | Image pull policy                               | `IfNotPresent`                                    |
| `image.tag`                | Image tag for the stable deployment             | `"v1.0.0-stable"`                                 |
| `canary.enabled`           | Enable the canary deployment                    | `false`                                           |
| `canary.tag`               | Image tag for the canary deployment             | `"v2.0.0-canary"`                                 |
| `service.type`             | Kubernetes service type                         | `ClusterIP`                                       |
| `service.port`             | Kubernetes service port                         | `3001`                                            |
| `istio.enabled`            | Enable Istio Gateway and VirtualService         | `false`                                           |
| `istio.host`               | Host for the Istio Gateway                      | `"*"`                                             |
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
