#####################################################################
# variables for module ingress-nginx
#####################################################################
variable "namespace" {
  default     = "ingress-nginx"
  description = "Namespace for this module."
}

variable "ip" {
  description = "IP for the nginx instance."
}

variable "nginx_image" {
  description = "Docker image for NGinx Ingress Controller."
}

variable "tls_certificate_path" {
  description = "Path to tls certificate file."
}

variable "tls_key_path" {
  description = "Path to tls key file."
}

