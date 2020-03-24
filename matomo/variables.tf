#####################################################################
# variables for module editor-renderer
#####################################################################
variable "image_tag" {
  description = "Docker image tag for editor-renderer."
  type        = string
}

variable "namespace" {
  default     = "matomo"
  description = "Namespace for all resources inside module editor-renderer."
}

variable "image_pull_policy" {
  type        = string
  description = "image pull policy usually Always for minikube should be set to Never"
  default     = "Always"
}

variable "container_limits_cpu" {
  type        = string
  description = "resources limits cpu for container"
  default     = "500m"
}

variable "container_limits_memory" {
  type        = string
  description = "resources limits memory for container"
  default     = "1Gi"
}

variable "container_requests_cpu" {
  type        = string
  description = "resources requests cpu for container"
  default     = "250m"
}

variable "container_requests_memory" {
  type        = string
  description = "resources requests memory for container"
  default     = "0.5Gi"
}

variable "app_replicas" {
  type        = number
  description = "number of replicas in the cluster"
  default     = 1
}

variable "database_user" {
  type        = string
  default     = "matomo"
  description = "Database username for default user that has also write privilege"
}

variable "database_password" {
  description = "Database password for default user that has also write privilege"
}

variable "database_host" {
  description = "Matomo database host"
}

variable "database_name" {
  type        = string
  default     = "matomo"
  description = "Database name to use for matomo data"
}
