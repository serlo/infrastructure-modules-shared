resource "helm_release" "hydra_deployment" {
  name       = "hydra"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "hydra"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 100

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        host            = var.host
        image_tag       = var.image_tag
        node_pool       = var.node_pool
        tls_secret_name = kubernetes_secret.hydra_tls_certificate.metadata.0.name
        dsn             = var.dsn
        salt            = random_password.hydra_salt.result
        url_login       = var.url_login
        url_logout      = var.url_logout
        url_consent     = var.url_consent
        system_secret   = random_password.hydra_system_secret.result
      }
    )
  ]
}

resource "random_password" "hydra_system_secret" {
  length  = 32
  special = false
}

resource "random_password" "hydra_salt" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "hydra_tls_certificate" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "hydra-tls-secret"
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
