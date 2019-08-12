#####################################################################
# variables for module varnish
#####################################################################
variable "namespace" {
  default     = "athene2"
  description = "Namespace for this module."
}

variable "app_replicas" {
  default     = 2
  description = "Number of application pods"
}

variable "image" {
  default     = "eu.gcr.io/serlo-shared/varnish:latest"
  description = "Docker image for varnish."
}

variable "backend_ip" {
  description = "IP of the default backend (athene2)."
}

variable "resources_limits_cpu" {
  type        = string
  description = "resources limits cpu for container"
  default     = "100m"
}

variable "resources_limits_memory" {
  type        = string
  description = "resources limits memory for container"
  default     = "1200Mi"
}

variable "resources_requests_cpu" {
  type        = string
  description = "resources requests cpu for container"
  default     = "100m"
}

variable "resources_requests_memory" {
  type        = string
  description = "resources requests memory for container"
  default     = "1200Mi"
}

variable "varnish_memory" {
  type        = string
  description = "varnish memory please correlate with resources_requests_memory and keep it 128 MB below this boundary"
  default     = "1G"
}

variable "image_pull_policy" {
  type        = string
  description = "image pull policy usually Always for minikube should be set to Never"
  default     = "Always"
}

variable "readiness_http_path" {
  type        = string
  description = "path for http request triggered by readiness probe"
  default     = "/health.php"
}