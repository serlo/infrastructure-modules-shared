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

variable "chart_versions" {
  description = "Chart version to use"
  type = object({
    rocketchat = string
    mongodb    = string
  })
}

variable "image_tags" {
  description = "Image tags to use"
  type = object({
    rocketchat = string
    mongodb    = string
  })
}

output "host" {
  value = var.host
}
