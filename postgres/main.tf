variable "postgres_password" {
  default = "admin"
}

variable "postgres_version" {
  default = "9.6"
}

variable "namespace" {
  description = "Namespace the database service should be created in"
}

variable "node_port" {
  description = "Node port for access of postgres minikube instance"
  default     = 30024
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace

    labels = {
      app = "postgres"
    }
  }

  spec {
    selector = {
      app = "postgres-app"
    }

    type = "NodePort"

    port {
      port        = 5432
      target_port = 5432
      node_port   = var.node_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres-pv-claim" {
  metadata {
    name      = "postgres-pv-claim"
    namespace = var.namespace

    labels = {
      app = "database-app"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-pass"
    namespace = var.namespace
  }

  data = {
    password = var.postgres_password
  }
}

resource "kubernetes_deployment" "postgres_deployment" {
  metadata {
    name      = "postgres-app"
    namespace = var.namespace

    labels = {
      app = "postgres-app"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = "postgres-app"
      }
    }

    template {
      metadata {
        labels = {
          app  = "postgres-app"
          name = "postgres"
        }
      }

      spec {
        container {
          image = "postgres:${var.postgres_version}"
          name  = "postgres"

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "password"
              }
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-persistent-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-persistent-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres-pv-claim.metadata[0].name
          }
        }
      }
    }
  }
}

