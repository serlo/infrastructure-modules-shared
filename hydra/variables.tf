variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "url_login" {
  description = "url of login provider"
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
