#####################################################################
# outputs for module matomo
#####################################################################
output "matomo_service_name" {
  value = kubernetes_service.matomo_service.metadata[0].name
}

output "matomo_service_port" {
  value = kubernetes_service.matomo_service.spec[0].port[0].port
}
