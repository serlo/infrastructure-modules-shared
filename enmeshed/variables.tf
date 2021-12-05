variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "host" {
  description = "Public host"
  type        = string
}

variable "image_tags" {
  description = "Image tags to use"
  type = object({
    enmeshed = string
    mongodb  = string
  })
}

variable "chart_versions" {
  description = "Helm chart versions to use"
  type = object({
    mongodb    = string
  })
}

variable "platform_client_id" {
  description = "Enmeshed platform client id"
  type        = string

}

variable "platform_client_secret" {
  description = "Enmeshed platform client secret"
  type        = string
}

variable "api_url" {
  description = "API URL"
  type        = string
}

variable "api_key" {
  description = "API key"
  type        = string
}