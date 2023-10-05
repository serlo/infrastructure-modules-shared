locals {
  name = "dbdump"
}

resource "kubernetes_cron_job_v1" "dbdump" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = var.schedule
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            node_selector = {
              "cloud.google.com/gke-nodepool" = var.node_pool
            }

            container {
              name  = "dbdump"
              image = var.image

              env {
                name  = "MYSQL_HOST"
                value = var.mysql.host
              }
              env {
                name  = "MYSQL_USER"
                value = var.mysql.username
              }
              env {
                name  = "MYSQL_PASSWORD"
                value = var.mysql.password
              }
              env {
                name  = "POSTGRES_HOST"
                value = var.postgres.host
              }
              env {
                name  = "POSTGRES_PASSWORD_READONLY"
                value = var.postgres.password
              }
              env {
                name  = "BUCKET_URL"
                value = var.bucket.url
              }
              env {
                name  = "BUCKET_SERVICE_ACCOUNT_KEY"
                value = var.bucket.service_account_key
              }
            }
          }
        }
      }
    }
  }
}
