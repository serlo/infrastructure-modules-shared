variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "schedule" {
  description = "Crontab-like schedule for the cron job"
  type        = string
}

variable "database" {
  description = "Legacy database connection configuration"
  type = object({
    host     = string
    username = string
    password = string
    name     = string
  })
}

variable "kratos_host" {
  type        = string
  description = "Kratos host dns"
}

locals {
  name = "kratos-import-users"
}

resource "kubernetes_cron_job" "kratos_import_users" {
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
        backoff_limit = 2
        template {
          metadata {}
          spec {
            node_selector = {
              "cloud.google.com/gke-nodepool" = var.node_pool
            }

            container {
              name  = "kratos-import-users"
              image = "node:16"
              args  = ["bash", "-c", "yarn init --yes && yarn add js-sha1 mysql @ory/client@0.2.0-alpha.4 && node /tmp/import-users.js"]

              volume_mount {
                mount_path = "/tmp/import-users.js"
                sub_path   = "import-users.js"
                name       = "import-users-volume"
                read_only  = true
              }
              resources {
                requests = {
                  "cpu"    = "200m"
                  "memory" = "250Mi"
                }
              }
            }

            volume {
              name = "import-users-volume"

              secret {
                secret_name = kubernetes_secret.kratos_import_users.metadata.0.name

                items {
                  key  = "import-users.js"
                  path = "import-users.js"
                  mode = "0444"
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "kratos_import_users" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    "import-users.js" = templatefile(
      "${path.module}/import-users.js.tpl",
      {
        database_host     = var.database.host
        database_username = var.database.username
        database_password = var.database.password
        database_name     = var.database.name
        kratos_host       = var.kratos_host
      }
    )
  }
}