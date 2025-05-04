# EKS Cluster Outputs
output "cluster_id" {
  value       = aws_eks_cluster.eks_cluster.cluster_id
}

output "cluster_arn" {
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
}


output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  value       = aws_eks_cluster.eks_cluster.version
}



output "cluster_oidc_issuer_url" {
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


output "eks_nodegroup_role_arn" {
  value       = aws_iam_role.eks_nodegroup_role.arn
}

