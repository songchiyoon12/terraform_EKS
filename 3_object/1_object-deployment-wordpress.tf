
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com" # EBS CSI 드라이버
  parameters = {
    type = "gp2" # gp2, io1 등도 가능
    fsType = "ext4"
  }
  reclaim_policy = "Delete"
  volume_binding_mode = "Immediate"
}



resource "kubernetes_persistent_volume_claim" "wordpress_pvc" {
  depends_on = [kubernetes_storage_class_v1.ebs_sc]
  metadata {
    name = "wordpress-data-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.ebs_sc.metadata[0].name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}


resource "kubernetes_deployment_v1" "wordpress" {
  depends_on = [kubernetes_persistent_volume_claim.wordpress_pvc]
  metadata {
    name = "wordpress-web"
    labels = {
      app = "wordpress-web"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "wordpress-web"
        tier = "frontend"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "wordpress-web"
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "wordpress:latest"
          name = "wordpress-web"
          env {
            name = "WORDPRESS_DB_HOST"
            value = aws_db_instance.my_rds.endpoint
          }
          env {
            name = "WORDPRESS_DB_USER"
            value = "admin"
          }
          env {
            name = "WORDPRESS_DB_NAME"
            value = "wordpress"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value= "wwoo3312"
          }
          port {
            container_port = 80
            name = "wordpress-web"
          }
          volume_mount {
            name = "wordpress-persistent-storage"
            mount_path = "/var/www/html"  # 마지막 슬래시 제거
          }
        }
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress_pvc.metadata[0].name
          }
        }
      }
    }
  }
}


