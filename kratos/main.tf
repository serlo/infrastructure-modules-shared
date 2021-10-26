variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "host" {
  type        = string
  description = "Public host of hydra"
}

variable "dsn" {
  description = "DSN string for Postgres database"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Hydra chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Hydra image tag to use"
}

variable "smtp_password" {
  type        = string
  description = "SMTP password"
}

resource "helm_release" "kratos_deployment" {
  name       = "kratos"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "kratos"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 100

  values = [
    data.template_file.values_yaml_template.rendered
  ]
}

data "template_file" "values_yaml_template" {
  template = file("${path.module}/values.yaml")

  vars = {
    host            = var.host
    image_tag       = var.image_tag
    tls_secret_name = kubernetes_secret.kratos_tls_certificate.metadata.0.name
    dsn             = var.dsn
    smtp_password   = var.smtp_password
    namespace       = var.namespace
    # salt            = random_password.kratos_salt.result
    # url_login       = var.url_login
    # url_logout      = var.url_logout
    # url_consent     = var.url_consent
    cookie_secret = random_password.kratos_cookie_secret.result
  }
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
  value = "http://kratos-admin.${var.namespace}:4445"
}

module "cert" {
  source = "../tls-self-signed-cert"
  domain = var.host
}
