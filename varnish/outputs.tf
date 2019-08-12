output "varnish_service_name" {
  value = kubernetes_service.varnish_service.metadata[0].name
}

output "varnish_service_port" {
  value = kubernetes_service.varnish_service.spec[0].port[0].port
}

