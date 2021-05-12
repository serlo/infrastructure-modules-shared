output "crt" {
  value = tls_self_signed_cert.crt.cert_pem
}

output "key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}
