variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "host" {
  description = "Public host of hydra"
  type        = string
}

variable "dsn" {
  description = "DSN string for Postgres database"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Kratos chart version to use"
}

variable "image_tag" {
  description = "Kratos image tag to use"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
}

variable "github" {
  description = "GitHub OAuth Client"
  type = object({
    client_id     = string
    client_secret = string
  })
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
    host                 = var.host
    image_tag            = var.image_tag
    tls_secret_name      = kubernetes_secret.kratos_tls_certificate.metadata.0.name
    dsn                  = var.dsn
    smtp_password        = var.smtp_password
    namespace            = var.namespace
    github_client_id     = var.github.client_id
    github_client_secret = var.github.client_secret
    cookie_secret        = random_password.kratos_cookie_secret.result
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
