variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Keycloak chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Keycloak image tag to use"
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "host" {
  type        = string
  description = "Public host of hydra"
}

variable "database" {
  type = object({
    host     = string
    user     = string
    password = string
    database = string
  })
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        host      = var.host
        image_tag = var.image_tag
        node_pool = var.node_pool

        database_host     = var.database.host
        database_user     = var.database.user
        database_password = var.database.password
        database_name     = var.database.database

        admin_password      = random_password.keycloak_admin_password.result
        management_password = random_password.wildfly_management_password.result
        tls_secret_name     = kubernetes_secret.keycloak_tls_certificate.metadata.0.name
      }
    )
  ]
}



resource "kubernetes_secret" "keycloak_tls_certificate" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "keycloak-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = module.cert.crt
    "tls.key" = module.cert.key
  }
}

resource "random_password" "keycloak_admin_password" {
  length  = 32
  special = false
}

resource "random_password" "wildfly_management_password" {
  length  = 32
  special = false
}

module "cert" {
  source = "../tls-self-signed-cert"
  domain = var.host
}
