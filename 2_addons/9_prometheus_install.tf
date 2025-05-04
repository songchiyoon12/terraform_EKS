
variable "namespace" {
  type    = string
  default = "monitoring"
}

resource "helm_release" "kube-prometheus" {
  depends_on = [helm_release.loadbalancer_controller]
  name             = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}


