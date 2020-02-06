variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "app_replicas" {
  description = "Number of rocket chat replicas"
  type        = number
}

variable "host" {
  description = "Public host"
  type        = string
}

variable "mongodump" {
  description = "Configuration for mongodump"
  type = object({
    image    = string
    schedule = string

    bucket_prefix = string
  })
}

variable "smtp_password" {
  type = string
}

variable "chart_version" {
  type        = string
  description = "Rocket Chat chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Rocket Chat image tag to use"
}

