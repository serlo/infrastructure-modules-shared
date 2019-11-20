resource "kubernetes_secret" "hydra_tls_certificate" {
  type = "kubernetes.io/tls"

  metadata {
    name = "hydra-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.tls_certificate_path
    "tls.key"  = var.tls_key_path
  }
}

data "helm_repository" "ory" {
  name = "ory"
  url  = "https://k8s.ory.sh/helm/charts"
}

resource "helm_release" "hydra_deployment" {
  name       = "hydra"
  repository = data.helm_repository.ory.metadata[0].name
  chart      = "hydra"
  namespace  = var.namespace
  timeout    = 100

  values = [
    file("${path.module}/config.yaml")
  ]

  set {
    name  = "hydra.config.secrets.system"
    value = random_string.hydra_system_secret.result
  }

  set {
    name  = "hydra.config.dsn"
    value = var.dsn
  }

  set {
    name  = "hydra.config.urls.self.issuer"
    value = "https://${var.public_host}"
  }

  set {
    name  = "hydra.config.urls.login"
    value = var.url_login
  }

  set {
    name  = "hydra.config.urls.consent"
    value = var.url_consent
  }

  set {
    name  = "hydra.config.oidc.subject_identifiers.pairwise.salt"
    value = var.salt
  }

  set {
    name  = "hydra.config.oidc.subject_identifiers.enabled"
    value = "pairwise"
  }

  set {
    name  = "hydra.autoMigrate"
    value = true
  }
}

resource "random_string" "hydra_system_secret" {
  length  = 32
  special = false
}
