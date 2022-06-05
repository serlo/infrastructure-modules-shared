
resource "tls_self_signed_cert" "crt" {
  private_key_pem = tls_private_key.key.private_key_pem

  validity_period_hours = 365 * 24
  early_renewal_hours   = 30 * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [var.domain]
  subject {
    common_name  = var.domain
    organization = "Serlo Education e.V."
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}
