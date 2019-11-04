resource "kubernetes_service" "hydra_service" {
  metadata {
    name      = "hydra-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.hydra_deployment.metadata[0].labels.app
    }

    port {
      port        = 4444
      target_port = 4444
    }

    port {
      port        = 4445
      target_port = 4445
    }


    type = "ClusterIP"
  }
}

resource "random_string" "system_secret" {
  length  = 32
  special = false
}

resource "kubernetes_deployment" "hydra_deployment" {
  metadata {
    name      = "hydra-app"
    namespace = var.namespace

    labels = {
      app = "hydra-app"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "hydra-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "hydra-app"
        }
      }

      spec {
        container {
          image             = var.image
          name              = "hydra-container"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "OAUTH2_EXPOSE_INTERNAL_ERRORS"
            value = 0
          }

          env {
            name  = "URLS_SELF_ISSUER"
            value = "http://localhost:4444"
          }

          env {
            name  = "URLS_LOGIN"
            value = var.url_login
          }

          env {
            name  = "URLS_CONSENT"
            value = var.url_consent
          }

          env {
            name  = "DSN"
            value = var.dsn
          }

          env {
            name  = "SECRETS_SYSTEM"
            value = random_string.system_secret.result
          }

          env {
            name  = "OIDC_SUBJECT_IDENTIFIERS_PAIRWISE_SALT"
            value = var.secret
          }

          liveness_probe {
            http_get {
              path = "/health/alive"
              port = 4445
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health/ready"
              port = 4445
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
        }
      }
    }
  }
}
