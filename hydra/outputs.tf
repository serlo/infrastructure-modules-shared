output "service_uri" {
  value = "https://${var.host}"
}

output "admin_uri" {
  value = "http://hydra-admin.${var.namespace}:4445"
}
