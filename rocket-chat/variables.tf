variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_tag" {
  description = "Rocket Chat image tag to use"
  type        = string
}

variable "host" {
  description = "Public host"
  type        = string
}
