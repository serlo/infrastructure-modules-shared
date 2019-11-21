variable "namespace" {
  description = "Namespace used"
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

variable "public_host" {
  type        = string
  description = "public url of hydra itself"
}

variable "dsn" {
  description = "DSN string for Postgres database"
  type        = string
}

variable "salt" {
  description = "Hydra pairwise salt. THIS SHOULD NEVER BE CHANGED AFTER SET IN PRODUCTION!"
  type        = string
}

variable "tls_certificate_path" {
  type        = string
  description = "Path to tls certificate"
}

variable "tls_key_path" {
  type        = string
  description = "Path to tls key"
}
