locals {
  name = "import-interest-job"
}

variable "namespace" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "mysql_database" {
  type = object({
    host     = string
    username = string
    password = string
  })
}

variable "postgres_database" {
  type = object({
    host     = string
    password = string
  })
}

resource "kubernetes_job" "kratos_import_interest" {
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
          command = ["bash", "-c", "echo $IMPORT_INTEREST_PY_BASE64 | base64 -d > /tmp/import-interest.py && pip install mysql-connector-python psycopg2-binary && python /tmp/import-interest.py"]
          env {
            name  = "MYSQL_HOST"
            value = var.mysql_database.host
          }
          env {
            name  = "MYSQL_USER"
            value = "serlo"
          }
          env {
            name  = "MYSQL_PASSWORD"
            value = var.mysql_database.password
          }
          env {
            name  = "POSTGRES_HOST"
            value = var.postgres_database.host
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_database.password
          }
          env {
            name  = "IMPORT_INTEREST_PY_BASE64"
            value = base64encode(file("${path.module}/import-interest.py"))
          }
        }
      }
    }
  }
}
