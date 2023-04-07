variable "namespace" {
  type = string
}

variable "host" {
  type        = string
  description = "Public host of kratos"
}

variable "domain" {
  type = string
}

variable "dsn" {
  description = "DSN string for Postgres database"
  type        = string
}

variable "chart_version" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "nbp_client_secret" {
  type = string
}

resource "helm_release" "kratos_deployment" {
  name       = "kratos"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "kratos"
  version    = var.chart_version
  namespace  = var.namespace
  # TODO: remove?
  timeout = 200

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        host              = var.host
        image_tag         = var.image_tag
        tls_secret_name   = kubernetes_secret.kratos_tls_certificate.metadata.0.name
        dsn               = var.dsn
        smtp_password     = var.smtp_password
        namespace         = var.namespace
        domain            = var.domain
        cookie_secret     = random_password.kratos_cookie_secret.result
        kratos_secret     = random_password.secret.result
        nbp_client_secret = var.nbp_client_secret
        mapper            = base64encode(file("${path.module}/user_mapper.jsonnet"))
      }
    )
  ]
}

resource "random_password" "kratos_cookie_secret" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "kratos_tls_certificate" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "kratos-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = module.cert.crt
    "tls.key" = module.cert.key
  }
}

output "service_uri" {
  value = "https://${var.host}"
}

output "admin_uri" {
  value = "http://kratos-admin.${var.namespace}"
}

output "public_uri" {
  value = "http://kratos-public.${var.namespace}"
}

module "cert" {
  source = "../tls-self-signed-cert"
  domain = var.host
}

resource "random_password" "secret" {
  length  = 32
  special = false
}

output "secret" {
  description = "Shared secret between api and kratos"
  value       = random_password.secret.result
  sensitive   = true
}