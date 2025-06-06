

resource "kubernetes_namespace_v1" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }
}




data "http" "get_cwagent_serviceaccount" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml"
  request_headers = {
    Accept = "text/*"
  }
}

data "kubectl_file_documents" "cwagent_docs" {
  content = data.http.get_cwagent_serviceaccount.body
}

resource "kubectl_manifest" "cwagent_serviceaccount" {
  depends_on = [kubernetes_namespace_v1.amazon_cloudwatch]
  for_each = data.kubectl_file_documents.cwagent_docs.manifests
  yaml_body = each.value
}

resource "kubernetes_config_map_v1" "cwagentconfig_configmap" {
  metadata {
    name = "cwagentconfig"
    namespace = kubernetes_namespace_v1.amazon_cloudwatch.metadata[0].name
  }
  data = {
    "cwagentconfig.json" = jsonencode({
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      }
    })
  }
}



data "http" "get_cwagent_daemonset" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml"
  # Optional request headers
  request_headers = {
    Accept = "text/*"
  }
}

resource "kubectl_manifest" "cwagent_daemonset" {
  depends_on = [
    kubernetes_namespace_v1.amazon_cloudwatch,
    kubernetes_config_map_v1.cwagentconfig_configmap,
    kubectl_manifest.cwagent_serviceaccount
  ]
  yaml_body = data.http.get_cwagent_daemonset.response_body
}

