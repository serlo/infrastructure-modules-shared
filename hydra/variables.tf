variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "url_login" {
  description = "url of login provider"
  type        = string
}

variable "url_logout" {
  description = "url of logout provider"
  type        = string
}

variable "url_consent" {
  description = "url of consent provider"
  type        = string
}

variable "host" {
  type        = string
  description = "Public host of hydra"
}

variable "dsn" {
  description = "DSN string for Postgres database"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Hydra chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Hydra image tag to use"
}
