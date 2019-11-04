#####################################################################
# variables for module legacy-editor-renderer
#####################################################################
variable "image" {
  description = "Docker image for hydra."
}

variable "namespace" {
  description = "Namespace for all resources inside module legacy-editor-renderer."
}

variable "image_pull_policy" {
  type        = string
  description = "image pull policy usually Always for minikube should be set to Never"
}

variable "container_limits_cpu" {
  type        = string
  description = "resources limits cpu for container"
}

variable "container_limits_memory" {
  type        = string
  description = "resources limits memory for container"
}

variable "container_requests_cpu" {
  type        = string
  description = "resources requests cpu for container"
}

variable "container_requests_memory" {
  type        = string
  description = "resources requests memory for container"
}

variable "app_replicas" {
  type        = number
  description = "number of replicas in the cluster"
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

variable "secret" {
  type        = string
  description = "Hydra pairwise salt. THIS SHOULD NEVER CHANGE AFTER SET IN PRODUCTION!"
}
