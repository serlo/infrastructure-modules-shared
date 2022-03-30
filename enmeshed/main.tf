locals {
  mongodb_uri = "mongodb://root:${random_password.mongodb_root_password.result}@enmeshed-database-mongodb-headless:27017/?authSource=admin&readPreference=primary&ssl=false"
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
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image = "ghcr.io/nmshd/connector:${var.image_tags.enmeshed}"
          name  = "connector"

          env {
            name  = "CUSTOM_CONFIG_LOCATION"
            value = "/config.json"
          }

          env {
            # To update the container whenever the config changes
            # See https://github.com/serlo/infrastructure-modules-shared/issues/21
            name  = "CONFIG_CHECKSUM"
            value = sha256(data.template_file.config_json_template.rendered)
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
            secret_name = "enmeshed-secret"
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "enmeshed_secret" {
  metadata {
    name      = "enmeshed-secret"
    namespace = var.namespace
  }

  data = {
    "config.json" = data.template_file.config_json_template.rendered
  }
}

data "template_file" "config_json_template" {
  template = file("${path.module}/config.json.tpl")

  vars = {
    platform_client_id     = var.platform_client_id
    platform_client_secret = var.platform_client_secret
    mongodb_uri            = local.mongodb_uri
    api_url                = var.api_url
    api_key                = var.api_key
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
    node_pool = var.node_pool

    mongodb_username        = "enmeshed" // necessary for chart
    mongodb_database        = "enmeshed-db"
    mongodb_root_password   = random_password.mongodb_root_password.result
    mongodb_replica_set_key = random_password.mongodb_replica_set_key.result
  }
}

resource "random_password" "mongodb_root_password" {
  length  = 32
  special = false
}

resource "random_password" "mongodb_replica_set_key" {
  length  = 32
  special = false
}
