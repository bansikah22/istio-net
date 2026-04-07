#------------------------------------------------------------------------------
# Istio Installation via Helm
#------------------------------------------------------------------------------
# This file manages the installation of Istio into the EKS cluster using the
# official Istio Helm charts. The installation is broken down into three
# sequential parts as recommended by the Istio documentation.

# 1. Istio Base
# This chart installs the Istio Custom Resource Definitions (CRDs) and other
# cluster-wide resources that the Istio control plane depends on.
# It must be installed first.
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.22.1"
  namespace  = "istio-system"
  create_namespace = true
}

# 2. Istiod (Control Plane)
# This chart installs the main Istio control plane components, including the
# discovery service, certificate authority, and sidecar injector.
# It explicitly depends on the `istio_base` release to ensure correct
# installation order. A 10-minute timeout is added to prevent failures on
# slower cluster provisioning.
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.22.1"
  namespace  = "istio-system"

  depends_on = [helm_release.istio_base]
  timeout    = 1200
}

# 3. Istio Ingress Gateway
# This chart installs the default Istio Ingress Gateway, which is a load
# balancer that exposes services to traffic from outside the mesh.
# It depends on the `istiod` control plane being ready. A 10-minute timeout
# is also added here for robustness.
# resource "helm_release" "istio_ingress" {
#   name       = "istio-ingress"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "gateway"
#   version    = "1.22.1"
#   namespace  = "istio-system"
#
#   depends_on = [helm_release.istiod]
#   timeout    = 1200
# }
