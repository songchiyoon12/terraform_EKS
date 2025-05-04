# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}"
  role_arn = aws_iam_role.eks_master_role.arn
  version = var.cluster_version


  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }


  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }


  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

data "aws_security_group" "eks_cluster_sg" {

  depends_on = [aws_eks_cluster.eks_cluster]

  filter {
    name   = "tag:Name"
    values = ["eks-cluster-sg-${var.cluster_name}-*"]
  }
}

resource "aws_ec2_tag" "karpenter_tag" {
  resource_id = data.aws_security_group.eks_cluster_sg.id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}