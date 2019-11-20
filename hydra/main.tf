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
    data.template_file.config_yaml_template.rendered
  ]
}

data "template_file" config_yaml_template {
  template = file("${path.module}/config.yaml.tpl")

  vars = {
    public_host: var.public_host
    tls_secret_name: kubernetes_secret.hydra_tls_certificate.metadata.0.name
    dsn: var.dsn
    salt: var.salt
    url_login: var.url_login
    url_consent: var.url_consent
    system_secret: random_string.hydra_system_secret.result
  }
}

resource "random_string" "hydra_system_secret" {
  length  = 32
  special = false
}
