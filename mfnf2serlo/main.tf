locals {
  name = "mfnf2serlo"
}

variable "namespace" {
  default = "kpi"
}

variable "node_pool" {
  type = string
}

variable "image_tag" {
  type        = string
  description = "See https://github.com/serlo/mfnf-to-edtr-mapping/tree/main/mfnf2serlo"
}

output "mfnf2serlo_service_name" {
  value = kubernetes_service.mfnf2serlo_service.metadata[0].name
}

output "mfnf2serlo_service_port" {
  value = kubernetes_service.mfnf2serlo_service.spec[0].port[0].port
}

resource "kubernetes_deployment" "mfnf2serlo" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app  = local.name
          name = local.name
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image = "eu.gcr.io/serlo-shared/mfnf2serlo:${var.image_tag}"
          name  = local.name

          resources {
            limits = {
              cpu    = "950m"
              memory = "150M"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "mfnf2serlo_service" {
  metadata {
    name      = "mfnf2serlo-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
