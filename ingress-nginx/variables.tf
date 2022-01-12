variable "namespace" {
  default     = "ingress-nginx"
  description = "Namespace for this module."
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
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
