resource "kubernetes_service" "matomo_service" {
  metadata {
    name      = "matomo-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.matomo_deployment.metadata[0].labels.app
    }

    port {
      port = 80
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "matomo_deployment" {
  metadata {
    name      = "matomo-app"
    namespace = var.namespace

    labels = {
      app = "matomo"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "matomo"
      }
    }

    template {
      metadata {
        labels = {
          app = "matomo"
        }
      }

      spec {
        container {
          image             = "matomo:${var.image_tag}"
          name              = "matomo-container"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "MATOMO_DATABASE_HOST"
            value = var.database_host
          }

          env {
            name  = "MATOMO_DATABASE_USERNAME"
            value = var.database_user
          }

          env {
            name  = "MATOMO_DATABASE_DBNAME"
            value = var.database_name
          }

          env {
            name = "MATOMO_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "database-password-default"
                name = kubernetes_secret.matomo_secret.metadata[0].name
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          resources {
            limits {
              cpu    = var.container_limits_cpu
              memory = var.container_limits_memory
            }

            requests {
              cpu    = var.container_requests_cpu
              memory = var.container_requests_memory
            }
          }

          volume_mount {
            mount_path = "/var/www/html/"
            name       = "matomo-config-storage"
          }
        }

        volume {
          name = "matomo-config-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.matomo_pvc.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "matomo_pvc" {
  metadata {
    name = "matomo-volume-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.matomo_volume.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "matomo_volume" {
  metadata {
    name = "matomo-volume"
  }
  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = var.persistent_disk_name
        fs_type = "ext4"
      }
    }
  }
}

resource "kubernetes_secret" "matomo_secret" {
  metadata {
    name      = "matomo-secret"
    namespace = var.namespace
  }

  data = {
    "database-password-default" = var.database_password
  }

  type = "Opaque"
}
