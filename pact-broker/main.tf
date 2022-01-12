variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_tag" {
  description = "Pakt Broker image tag to use"
  type        = string
}

variable "image_pull_policy" {
  description = "image pull policy"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "database" {
  description = "Database connection information"
  type = object({
    host     = string
    name     = string
    username = string
    password = string
  })
}

resource "kubernetes_service" "pact" {
  metadata {
    name      = "pact"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.pact.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 9292
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "pact" {
  metadata {
    name      = "pact-broker"
    namespace = var.namespace

    labels = {
      app = "pact-broker"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "pact-broker"
      }
    }

    template {
      metadata {
        labels = {
          app = "pact-broker"
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image             = "pactfoundation/pact-broker:${var.image_tag}"
          name              = "pact-broker"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "PACT_BROKER_DATABASE_ADAPTER"
            value = "postgres"
          }

          env {
            name  = "PACT_BROKER_DATABASE_USERNAME"
            value = var.database.username
          }

          env {
            name  = "PACT_BROKER_DATABASE_PASSWORD"
            value = var.database.password
          }

          env {
            name  = "PACT_BROKER_DATABASE_HOST"
            value = var.database.host
          }

          env {
            name  = "PACT_BROKER_DATABASE_NAME"
            value = var.database.name
          }

          env {
            name  = "PACT_BROKER_BASIC_AUTH_USERNAME"
            value = "pact"
          }

          env {
            name  = "PACT_BROKER_BASIC_AUTH_PASSWORD"
            value = random_password.pact_password.result
          }

          env {
            name  = "PACT_BROKER_ALLOW_PUBLIC_READ"
            value = "true"
          }

          env {
            name  = "PACT_BROKER_PUBLIC_HEARTBEAT"
            value = "true"
          }

          liveness_probe {
            http_get {
              path = "/diagnostic/status/heartbeat"
              port = 9292
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }
        }
      }
    }
  }
}

output "service_name" {
  value = kubernetes_service.pact.metadata[0].name
}

output "service_port" {
  value = kubernetes_service.pact.spec[0].port[0].port
}

resource "random_password" "pact_password" {
  length  = 32
  special = false
}
