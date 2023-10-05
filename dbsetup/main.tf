locals {
  name = "dbsetup"
}

resource "kubernetes_cron_job_v1" "dbsetup" {
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
              name  = local.name
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
                name  = "MYSQL_PORT"
                value = "3306"
              }
              env {
                name  = "POSTGRES_HOST"
                value = var.postgres.host
              }
              env {
                name  = "POSTGRES_PASSWORD"
                value = var.postgres.password
              }
              env {
                name  = "GCLOUD_BUCKET_URL"
                value = var.bucket.url
              }
              env {
                name  = "GCLOUD_SERVICE_ACCOUNT_NAME"
                value = var.bucket.service_account_name
              }
              env {
                name  = "GCLOUD_SERVICE_ACCOUNT_KEY"
                value = var.bucket.service_account_key
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "dbsetup_secret" {
  metadata {
    name      = "dbsetup-secret"
    namespace = var.namespace
  }

  data = {
    "database-password-default" = var.mysql.password
    "credential.json"           = var.bucket.service_account_key
  }

  type = "Opaque"
}
