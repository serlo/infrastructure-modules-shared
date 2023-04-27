locals {
  name = "sync-accounts-job"
}

variable "namespace" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "postgres_database" {
  type = object({
    host     = string
    password = string
  })
  sensitive = true
}

# We could make it a cron job, but since it would mean a connection more to our db, let's wait for the need first
resource "kubernetes_job" "kratos_sync_accounts" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = local.name
          image   = "python:3.8"
          command = ["bash", "-c", "echo $SYNC_ACCOUNTS_PY_BASE64 | base64 -d > /tmp/sync-accounts.py && pip install ory_client requests psycopg2-binary && python /tmp/sync-accounts.py"]
          env {
            name  = "POSTGRES_HOST"
            value = var.postgres_database.host
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_database.password
          }
          env {
            name  = "SYNC_ACCOUNTS_PY_BASE64"
            value = base64encode(file("${path.module}/sync-accounts.py"))
          }
        }
      }
    }
  }
}
