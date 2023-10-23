variable "namespace" {
  type = string
}

variable "chart_version" {
  type = string
}

variable "platform_client_id" {
  type = string
}

variable "platform_client_secret" {
  type = string
}

variable "api_url" {
  type = string
}

variable "api_key" {
  type = string
}

variable "transport_base_url" {
  type = string
}

resource "helm_release" "enmeshed_deployment" {
  name      = "enmeshed"
  chart     = " oci://ghcr.io/nmshd/connector-helm-chart"
  version   = var.chart_version
  namespace = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        mongodb_uri            = "mongodb://root:${random_password.mongodb_root_password.result}@mongodb:27017/?authSource=admin&readPreference=primary&ssl=false"
        platform_client_id     = var.platform_client_id
        platform_client_secret = var.platform_client_secret
        transport_base_url     = var.transport_base_url
        api_url                = var.api_url
        api_key                = var.api_key
      }
    )
  ]
}

resource "helm_release" "database" {
  name       = "mongodb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "14.0.12"
  namespace  = var.namespace

  values = [
    templatefile(
      "${path.module}/values-mongodb.yaml",
      {
        mongodb_root_password = random_password.mongodb_root_password.result
    })
  ]
}


resource "random_password" "mongodb_root_password" {
  length  = 32
  special = false
}
