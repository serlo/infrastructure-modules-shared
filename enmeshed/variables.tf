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
