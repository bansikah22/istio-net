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

## Step 5: Enable the Ingress Gateway

To expose our application to traffic from outside the cluster, we need to use the Istio Ingress Gateway. Minikube has a special command to create a tunnel to the gateway service.

1.  **Open a new terminal window.** Do not close your existing terminal.
2.  **Start the Minikube tunnel:**
    Run the following command in the **new** terminal. This command will run continuously, creating a network route from your local machine to the services inside the Minikube cluster.

    ```bash
    minikube tunnel
    ```

    Keep this terminal window open. You can now access the Istio Ingress Gateway using the `EXTERNAL-IP` address shown in the `kubectl get svc` command for `istio-ingressgateway`.

Your local Kubernetes and Istio environment is now ready! You can proceed with deploying the application.
