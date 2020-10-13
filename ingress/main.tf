# Creates an Ingress (w/ optional TLS support) to expose services
#
# see https://www.terraform.io/docs/providers/kubernetes/r/ingress.html
resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = var.name
    namespace = var.namespace

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "2M"
    }
  }

  spec {
    rule {
      host = var.host

      http {
        path {
          path = "/"

          backend {
            service_name = var.backend.service_name
            service_port = var.backend.service_port
          }
        }
      }
    }

    tls {
      hosts       = var.enable_tls ? [var.host] : []
      secret_name = var.enable_tls ? kubernetes_secret.tls_certificate.0.metadata.0.name : null
    }
  }
}

# Creates a self-signed TLS certificate
#
# see https://www.terraform.io/docs/providers/kubernetes/d/secret.html
resource "kubernetes_secret" "tls_certificate" {
  count = var.enable_tls ? 1 : 0

  type = "kubernetes.io/tls"

  metadata {
    name      = "${var.name}-tls"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = module.cert.crt
    "tls.key" = module.cert.key
  }
}

module "cert" {
  source = "../tls-self-signed-cert"
  domain = var.host
}

variable name {
  description = "Name of the resource"
  type        = string
}

variable namespace {
  description = "K8s namespace to use"
  type        = string
}

variable host {
  description = "Fully qualified domain name"
  type        = string
}

variable backend {
  description = "Backend defines the referenced service endpoint to which the traffic will be forwarded to"
  type = object({
    service_name = string
    service_port = string
  })
}

variable enable_tls {
  description = "Whether to enable TLS"
  type        = bool
}
