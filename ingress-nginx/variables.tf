variable "namespace" {
  default     = "ingress-nginx"
  description = "Namespace for this module."
}

variable "ip" {
  description = "IP for the nginx instance"
  type        = string
}

variable "domain" {
  description = "Domain for the nginx instance"
  type        = string
}

variable "nginx_image" {
  description = "Docker image for NGinx Ingress Controller."
}
