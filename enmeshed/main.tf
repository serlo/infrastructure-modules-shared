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
          resources {
            limits {
              cpu    = "1000m"
              memory = "2000Mi"
            }
            requests {
              cpu    = "750m"
              memory = "1500Mi"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/config.json"
            sub_path   = "config.json"
            read_only  = true
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


resource "kubernetes_service" "enmeshed_service" {
  metadata {
    name      = "enmeshed-service"
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
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "helm_release" "database" {
  name       = "enmeshed-database"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = var.chart_versions.mongodb
  namespace  = var.namespace

  values = [
    data.template_file.mongodb_values.rendered
  ]
}

data "template_file" "mongodb_values" {
  template = file("${path.module}/values-mongodb.yaml")

  vars = {
    image_tag = var.image_tags.mongodb

    mongodb_database        = "enmeshed-db"
    mongodb_username        = "enmeshed"
    mongodb_password        = random_password.mongodb_password.result
    mongodb_root_password   = random_password.mongodb_root_password.result
    mongodb_replica_set_key = random_password.mongodb_replica_set_key.result
  }
}

resource "random_password" "mongodb_password" {
  length  = 32
  special = false
}

resource "random_password" "mongodb_root_password" {
  length  = 32
  special = false
}

resource "random_password" "mongodb_replica_set_key" {
  length  = 32
  special = false
}
