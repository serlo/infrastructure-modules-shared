resource "kubernetes_service" "varnish_service" {
  metadata {
    name      = "varnish-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.varnish_deployment.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "varnish_deployment" {
  metadata {
    name      = "varnish-app"
    namespace = var.namespace

    labels = {
      app = "varnish"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "varnish"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          app = "varnish"
        }
      }

      spec {
        container {
          image             = var.image
          name              = "varnish-container"
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 80
          }

          env {
            name  = "VARNISH_MEMORY"
            value = var.varnish_memory
          }

          # This ensures that changes to the config file trigger a redeployment
          env {
            name  = "CONFIG_CHECKSUM"
            value = sha256(data.template_file.default_vcl_template.rendered)
          }

          readiness_probe {
            http_get {
              path = var.readiness_http_path
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
              cpu    = var.resources_limits_cpu
              memory = var.resources_limits_memory
            }

            requests {
              cpu    = var.resources_requests_cpu
              memory = var.resources_requests_memory
            }
          }

          volume_mount {
            name       = "varnish-config-volume"
            mount_path = "/etc/varnish/default.vcl"
            sub_path   = "default.vcl"
          }
        }

        volume {
          name = "varnish-config-volume"

          config_map {
            name = kubernetes_config_map.athene2_varnish_vcl.metadata.0.name

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

data "template_file" "default_vcl_template" {
  template = file("${path.module}/default.vcl")

  vars = {
    backend_ip = var.backend_ip
  }
}

resource "kubernetes_config_map" "athene2_varnish_vcl" {
  metadata {
    name      = "athene2-varnish-vcl"
    namespace = var.namespace

    labels = {
      app = "varnish"
    }
  }

  data = {
    "default.vcl" = data.template_file.default_vcl_template.rendered
  }
}
