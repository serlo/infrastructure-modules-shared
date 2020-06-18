locals {
  name = "varnish"
}

variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to use"
  type        = string
}

variable "image_pull_policy" {
  description = "image pull policy"
  type        = string
}

variable "host" {
  description = "Host of the backend"
  type        = string
}

variable "readiness_probe_http_path" {
  description = "Path for HTTP GET request triggered by readiness probe"
  type        = string
}

resource "kubernetes_service" "varnish" {
  metadata {
    name      = local.name
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

output "service_name" {
  value = kubernetes_service.varnish.metadata[0].name
}

output "service_port" {
  value = kubernetes_service.varnish.spec[0].port[0].port
}


resource "kubernetes_deployment" "varnish" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          image             = "eu.gcr.io/serlo-shared/varnish:${var.image_tag}"
          name              = local.name
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 80
          }

          env {
            name  = "VARNISH_MEMORY"
            value = "500M"
          }

          # This ensures that changes to the config file trigger a redeployment
          env {
            name  = "CONFIG_CHECKSUM"
            value = sha256(data.template_file.varnish.rendered)
          }

          readiness_probe {
            http_get {
              path = var.readiness_probe_http_path
              port = 80
            }

            initial_delay_seconds = 5
            period_seconds        = 30
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 10
          }

          resources {
            limits {
              cpu    = "75m"
              memory = "750Mi"
            }

            requests {
              cpu    = "50m"
              memory = "500Mi"
            }
          }

          volume_mount {
            name       = local.name
            mount_path = "/etc/varnish/default.vcl"
            sub_path   = "default.vcl"
          }
        }

        volume {
          name = local.name

          config_map {
            name = kubernetes_config_map.varnish.metadata.0.name

            items {
              key  = "default.vcl"
              path = "default.vcl"
              mode = "0444"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "varnish" {
  metadata {
    name      = "default.vcl"
    namespace = var.namespace
  }

  data = {
    "default.vcl" = data.template_file.varnish.rendered
  }
}

data "template_file" "varnish" {
  template = file("${path.module}/default.vcl")

  vars = {
    host = var.host
  }
}

