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

variable "nbp_client" {
  type = object({
    id     = string
    secret = string
  })
}

variable "newsletter_api_key" {
  type = string
}

resource "helm_release" "kratos_deployment" {
  name       = "kratos"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "kratos"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        host            = var.host
        image_tag       = var.image_tag
        tls_secret_name = kubernetes_secret.kratos_tls_certificate.metadata.0.name
        dsn             = var.dsn
        smtp_password   = var.smtp_password
        namespace       = var.namespace
        domain          = var.domain
        cookie_secret   = random_password.kratos_cookie_secret.result
        kratos_secret   = random_password.secret.result
        # TODO: remove ternary operators and sso_enabled variable once we want SSO also in production
        nbp_client_id               = var.nbp_client.id != "" ? var.nbp_client.id : "anything otherwise the yml will be invalid"
        nbp_client_secret           = var.nbp_client.secret != "" ? var.nbp_client.secret : "anything otherwise the yml will be invalid"
        sso_enabled                 = var.nbp_client.secret != "" ? true : false
        identity_schema             = base64encode(file("${path.module}/identity.schema.json"))
        nbp_user_mapper             = base64encode(file("${path.module}/nbp_user_mapper.jsonnet"))
        user_id_mapper              = base64encode("function (ctx) { userId: ctx.identity.id }")
        newsletter_api_key          = var.newsletter_api_key
        mailchimp_server            = split("-", var.newsletter_api_key)[1]
        subscribe_newsletter_mapper = base64encode(file("${path.module}/subscribe_newsletter_mapper.jsonnet"))
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
