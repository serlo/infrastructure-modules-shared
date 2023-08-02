locals {
  name = "notification-mail"
}

variable "namespace" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "api_graphql_url" {
  type = string
}

variable "db_uri" {
  type = string
}

variable "smtp_uri" {
  type = string
}

variable "from_email" {
  type    = string
  default = "notifications@mail.serlo.org"
}

resource "kubernetes_cron_job_v1" "notification_mail" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = "0 0 * * *"
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            node_selector = {
              "cloud.google.com/gke-nodepool" = var.node_pool
            }

            container {
              name  = local.name
              image = "eu.gcr.io/serlo-shared/${local.name}:${var.image_tag}"

              env {
                name  = "SERLO_API_GRAPHQL_URL"
                value = var.api_graphql_url
              }
              env {
                name  = "SERLO_API_NOTIFICATION_EMAIL_SERVICE_SECRET"
                value = random_password.secret.result
              }
              env {
                name  = "DB_URI"
                value = var.db_uri
              }
              env {
                name  = "SMTP_URI"
                value = var.smtp_uri
              }
              env {
                name  = "FROM_EMAIL"
                value = var.from_email
              }
            }
            restart_policy = "Never"
          }
        }
      }
    }
  }
}

resource "random_password" "secret" {
  length  = 32
  special = false
}

output "secret" {
  description = "Shared secret between api and notification-mail-service"
  value       = random_password.secret.result
  sensitive   = true
}
