#####################################################################
# Outputs for module legacy-editor-renderer
#####################################################################
output "cluster_ip" {
  value     = kubernetes_service.hydra_service.spec[0].cluster_ip
  sensitive = true
}

output "service_uri" {
  value     = "http://${kubernetes_service.hydra_service.spec[0].cluster_ip}:${kubernetes_service.hydra_service.spec[0].port[0].port}"
  sensitive = true
}

output "admin_uri" {
  value     = "http://${kubernetes_service.hydra_service.spec[0].cluster_ip}:${kubernetes_service.hydra_service.spec[0].port[1].port}"
  sensitive = true
}
