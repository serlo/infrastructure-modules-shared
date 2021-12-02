output "enmeshed_connector_service_name" {
  value = kubernetes_service.enmeshed_service.metadata.0.name
}

output "enmeshed_connector_service_port" {
  value = kubernetes_service.enmeshed_service.spec[0].port[0].port
}
