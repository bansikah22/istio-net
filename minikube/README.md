# Local Development with Minikube

This guide provides instructions for setting up a local Kubernetes and Istio environment using Minikube. This is a fast, reliable, and free way to complete the hands-on exercises for your CKA and ICA exam preparation.

## Prerequisites

Before you begin, you must have a container or virtual machine manager installed on your system, such as:

*   [Docker](https://docs.docker.com/get-docker/) (Recommended)
*   [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) (Windows)
*   [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (Windows, macOS, Linux)
*   [KVM](https://www.linux-kvm.org/page/Downloads) (Linux)

## Step 1: Install Minikube

Minikube is a command-line tool that provisions and manages single-node Kubernetes clusters on your local machine.

Follow the official installation instructions for your operating system:
[https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)

## Step 2: Start the Minikube Cluster

To run Istio and our sample application, you need to start a Minikube cluster with sufficient resources. We recommend at least **4 CPU cores** and **8 GB of RAM**.

1.  **Start the cluster:**
    Open your terminal and run the following command. This will create a new Kubernetes cluster using the recommended settings. If you are using a driver other than Docker, replace `docker` with your driver of choice (e.g., `virtualbox`, `kvm2`).

    ```bash
    minikube start --cpus 4 --memory 8192 --driver=docker
    ```

2.  **Verify the cluster:**
    After the command completes, verify that your cluster is running and `kubectl` is configured to connect to it.

    ```bash
    kubectl get nodes
    ```

    You should see a single node with the status `Ready`.

## Step 3: Install the Istio CLI (istioctl)

`istioctl` is a command-line tool that allows you to install and manage Istio in your cluster.

1.  **Download and install `istioctl`:**
    Follow the official Istio instructions to download and install the tool:
    [https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/)

    The simplest method is often the download script:
    ```bash
    curl -L https://istio.io/downloadIstio | sh -
    ```
    This will download Istio to a directory. You will need to add the `istioctl` binary from that directory to your system's PATH.

## Step 4: Install Istio on Minikube

Now that your cluster is running and `istioctl` is installed, you can install the Istio control plane.

1.  **Install Istio:**
    We will use the `demo` profile, which is a good starting point for learning and includes the core components as well as tools like Prometheus, Grafana, and Kiali for observability.

    ```bash
    istioctl install --set profile=demo -y
    ```

2.  **Verify the Istio installation:**
    Check that the Istio pods have been created in the `istio-system` namespace and are running.

    ```bash
    kubectl get pods -n istio-system
    ```

    You should see pods for `istiod`, `istio-egressgateway`, and `istio-ingressgateway`, among others.

## Step 5: Install Observability Addons (Kiali & Prometheus)

To visualize your service mesh and view traffic flowing through it, you need to install the Kiali dashboard and Prometheus (which collects the metrics that Kiali uses).

1.  **Install the addons manually:**
    This approach avoids the need to download the full Istio release. Apply the manifests directly from the official Istio repository (replace `1.29` with your desired Istio version).
    
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.29/samples/addons/prometheus.yaml
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.29/samples/addons/kiali.yaml
    ```

2.  **Verify installation:**
    ```bash
    kubectl get pods -n istio-system | grep -E 'kiali|prometheus'
    ```

3.  **Configure Ingress for Dashboards:**
    To provide stable URLs for Kiali and Prometheus, apply the pre-configured Ingress resources. These use Istio `Gateways` and `VirtualServices` to route traffic from a unique hostname to each service.
    ```bash
    kubectl apply -f minikube/kiali-ingress.yaml
    kubectl apply -f minikube/prometheus-ingress.yaml
    ```
    
    *(Note: You will need to update the hostnames in these files with the correct external IP of your ingress gateway, as described in Step 6).*

## Step 6: Access Services

With the `minikube tunnel` running, you can now access all services.

1.  **Find the Ingress Gateway IP:**
    In a new terminal, get the external IP address of the gateway:
    ```bash
    kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    ```

2.  **Construct the URLs:**
    Use the IP from the previous step to access the services. No `/etc/hosts` file editing is needed.
    -   **Prime Calculator Application:** `http://app.<YOUR_GATEWAY_IP>.nip.io`
    -   **Kiali Dashboard:** `http://kiali.<YOUR_GATEWAY_IP>.nip.io`
    -   **Prometheus UI:** `http://prometheus.<YOUR_GATEWAY_IP>.nip.io`

## Step 7: Enable Strict mTLS (Optional)

To enforce encrypted communication between services within the mesh, you can apply a `PeerAuthentication` policy. This will cause Kiali to display a "lock" icon on the traffic graph.

1.  **Apply the policy:**
    ```bash
    kubectl apply -f minikube/mtls-policy.yaml
    ```
Your local Kubernetes and Istio environment is now ready!

## Canary Deployment Notes

The included Helm chart (`charts/prime-calculator`) is pre-configured for canary deployments. When you enable `canary.enabled=true` in `values.yaml` (or via a `--set` flag), the `VirtualService` is automatically configured to split traffic. By default, it sends **90%** of requests to the `stable` deployment and **10%** to the `canary` deployment. This ratio is defined in `charts/prime-calculator/templates/istio-virtualservice.yaml` and can be customized as needed.
