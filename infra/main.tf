#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
# Creates a dedicated Virtual Private Cloud (VPC) for the EKS cluster.
# This VPC is configured with public and private subnets across three
# availability zones for high availability.
# The public subnets are tagged for use by Kubernetes load balancers (ELB),
# and the private subnets are tagged for internal load balancers.
# A single NAT Gateway is enabled to allow outbound internet access
# for resources in the private subnets (e.g., worker nodes).
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.cluster_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                     = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }
}

#------------------------------------------------------------------------------
# EKS Cluster
#------------------------------------------------------------------------------
# Provisions an Amazon EKS (Elastic Kubernetes Service) cluster.
# The cluster is configured with a specific Kubernetes version required for
# CKA exam preparation (v1.34).
# The control plane is placed in the private subnets of the VPC created above.
# The public API endpoint is enabled to allow `kubectl` and Terraform to
# manage the cluster from outside the VPC.
#
# A managed node group is created to provide compute capacity for the cluster.
# These nodes will run in the private subnets and use an Amazon Linux 2023 AMI,
# which is compatible with Kubernetes v1.34.
# The node group is configured to scale between 1 and 3 nodes.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # This is enabled to allow Terraform and local kubectl to access the cluster API.
  # For a production environment, this would ideally be false, and a bastion host
  # or VPN would be used for access.
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Explicitly add a security group rule to allow HTTPS traffic from anywhere
  # to the EKS control plane. This can help resolve TLS handshake timeouts
  # when the default rules are not sufficient.
  cluster_security_group_additional_rules = {
    public_api_access = {
      description = "Allow public access to EKS API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.large"]
      # AL2023 is required for Kubernetes versions 1.33+
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}
