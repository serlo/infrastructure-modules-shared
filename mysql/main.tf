variable "mysql_password" {
  default = "admin"
}

variable "mysql_version" {
  default = "5.7"
}

variable "namespace" {
  description = "Namespace the database service should be created in"
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace

    labels = {
      app = "mysql-app"
    }
  }

  spec {
    selector = {
      app = "mysql-app"
    }

    type = "NodePort"

    port {
      port        = 3306
      target_port = 3306
      node_port   = var.node_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql-pv-claim" {
  metadata {
    name      = "mysql-pv-claim"
    namespace = var.namespace

    labels = {
      app = "mysql_app"
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

resource "kubernetes_secret" "mysql" {
  metadata {
    name      = "mysql-pass"
    namespace = var.namespace
  }

  data = {
    password = var.mysql_password
  }
}

resource "kubernetes_deployment" "mysql_deployment" {
  metadata {
    name      = "mysql-app"
    namespace = var.namespace

    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = "mysql-app"
      }
    }

    template {
      metadata {
        labels = {
          app  = "mysql-app"
          name = "mysql"
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image = "mysql:${var.mysql_version}"
          name  = "mysql"

          env {
            name = "MYSQL_ROOT_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql.metadata[0].name
                key  = "password"
              }
            }
          }

          port {
            container_port = 3306
          }

          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "mysql-persistent-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql-pv-claim.metadata[0].name
          }
        }
      }
    }
  }
}
