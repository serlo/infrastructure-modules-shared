#####################################################################
# Outputs for module legacy-editor-renderer
#####################################################################

output "service_uri" {
  value     = "https://${var.public_host}"
}

output "admin_uri" {
  value     = "http://hydra-admin.${var.namespace}:4445"
}
