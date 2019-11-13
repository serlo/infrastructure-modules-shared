#####################################################################
# variables for module legacy-editor-renderer
#####################################################################
variable "namespace" {
  description = "Namespace for all resources inside module legacy-editor-renderer."
}

variable "url_login" {
  type = string
  description = "url of login provider"
}

variable "url_consent" {
  type = string
  description = "url of consent provider"
}

variable "dsn" {
  type        = string
  description = "DSN string for Postgres database"
}

variable "salt" {
  type        = string
  description = "Hydra pairwise salt. THIS SHOULD NEVER CHANGE AFTER SET IN PRODUCTION!"
}
