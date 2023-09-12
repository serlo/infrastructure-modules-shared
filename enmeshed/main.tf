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
  name = "enmeshed"
  # repository = "https://ghcr.io/nmshd"
  chart     = " oci://ghcr.io/nmshd/connector-helm-chart"
  version   = var.chart_version
  namespace = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        platform_client_id     = var.platform_client_id
        platform_client_secret = var.platform_client_secret
        transport_base_url     = var.transport_base_url
        api_url                = var.api_url
        api_key                = var.api_key
      }
    )
  ]
}

