
resource "helm_release" "metrics_server_release" {
  name       = "${var.cluster_name}-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace = "kube-system"
}


