/*
resource "kubernetes_service_v1" "wordpress_service" {
  metadata {
    name = "nodeport-service"
    annotations = {
      #Important Note:  Need to add health check path annotations in service level if we are planning to use multiple targets in a load balancer
      #"alb.ingress.kubernetes.io/healthcheck-path" = "/index.html"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.wordpress.spec.0.selector.0.match_labels.ap
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_class_v1" "ingress_class" {
  metadata {
    name = "my-aws-ingress-class"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }
  spec {
    controller = "ingress.k8s.aws/alb"
  }
}




# Kubernetes Service Manifest (Type: Load Balancer)
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "ingress-basics"
    annotations = {
      # Load Balancer Name
      "alb.ingress.kubernetes.io/load-balancer-name" = "myeks-alb"
      # Ingress Core Settings
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      # SSL 설정
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/certificate-arn" =  var.ACM_DOMAIN # 실제 ACM 인증서 ARN으로 변경
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"

      # 도메인 관련 설정
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "external-dns.alpha.kubernetes.io/hostname" = "gold.songchiaws.shop"
      "external-dns.alpha.kubernetes.io/record-type" = "A"

      # Health Check Settings
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port" = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = 15
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = 5
      "alb.ingress.kubernetes.io/success-codes" = 200
      "alb.ingress.kubernetes.io/healthy-threshold-count" = 2
      "alb.ingress.kubernetes.io/unhealthy-threshold-count" = 2
    }
  }
  spec {
    ingress_class_name = kubernetes_ingress_class_v1.ingress_class.metadata[0].name

    # 호스트 기반 라우팅 추가
    rule {
      host = "gold.songchiaws.shop"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.wordpress_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}


 */

