variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Redis chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Redis image tag to use"
}
