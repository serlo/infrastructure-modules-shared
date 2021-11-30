locals {
  mongodb_uri = "mongodb://mongo:pass@enmeshed-db:27017/enmeshed-db"
}

resource "kubernetes_deployment" "enmeshed_deployment" {
  metadata {
    name      = "enmeshed-deployment"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "enmeshed-app"
      }
    }

    template {
      metadata {
        namespace = var.namespace
        labels = {
          app = "enmeshed-app"
        }
      }
      spec {
        container {
          image = "ghcr.io/nmshd/connector:${var.image_tags.enmeshed}"
          name  = "connector"

          env {
            name  = "CUSTOM_CONFIG_LOCATION"
            value = "/config.json"
          }
          # TODO
          #          resources {
          #            limits   = {
          #              cpu    = "1000m"
          #              memory = "2000Mi"
          #            }
          #            requests = {
          #              cpu    = "750m"
          #              memory = "1500Mi"
          #            }
          #          }
          volume_mount {
            name       = "config"
            mount_path = "/config.json"
          }
        }

        volume {
          name = "config"

          secret {
            secret_name = "config.json"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "enmeshed" {
  metadata {
    name      = "enmeshed"
    namespace = var.namespace

    labels = {
      app = "enmeshed-app"
    }
  }

  spec {
    selector = {
      app = "enmeshed-app"
    }

    type = "NodePort"

    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = var.namespace

    labels = {
      app = "mongodb-app"
    }
  }

  spec {
    selector = {
      app = "mongodb-app"
    }

    type = "NodePort"

    port {
      port        = 27017
      target_port = 27017
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mongodb-pv-claim" {
  metadata {
    name      = "mongodb-pv-claim"
    namespace = var.namespace

    labels = {
      app = "mongodb-app"
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

resource "kubernetes_deployment" "mongodb_deployment" {
  metadata {
    name      = "mongodb-app"
    namespace = var.namespace

    labels = {
      app = "mongodb-app"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = "mongodb-app"
      }
    }

    template {
      metadata {
        labels = {
          app  = "mongodb-app"
          name = "mongodb"
        }
      }

      spec {
        container {
          image = "mongo:${var.image_tags.mongodb}"
          name  = "mongodb"

          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "mongo"
          }

          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = "pass"
          }

          port {
            container_port = 3306
          }

          volume_mount {
            name       = "mongodb-persistent-storage"
            mount_path = "/data/db"
          }
        }

        volume {
          name = "mongodb-persistent-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb-pv-claim.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_ingress" "enmeshed_ingress" {
  metadata {
    name      = "enmeshed-public"
    namespace = var.namespace
  }

  spec {
    backend {
      service_name = "enmeshed"
      service_port = 80
    }

    rule {
      host = var.host
      http {
        path {
          backend {
            service_name = "enmeshed"
            service_port = 8080
          }

          path = "/"
        }
      }
    }
    # TODO
    #    tls {
    #      secret_name = "tls-secret"
    #    }
  }
}

