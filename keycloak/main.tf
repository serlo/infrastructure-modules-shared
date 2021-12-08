variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "chart_version" {
  type        = string
  description = "Keycloak chart version to use"
}

variable "image_tag" {
  type        = string
  description = "Keycloak image tag to use"
}

variable "database" {
  type = object({
    host     = string
    user     = string
    password = string
    database = string
  })
}


resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 100

  set {
    name  = "postgresql.enabled"
    value = false
  }

  set {
    name  = "externalDatabase.host"
    value = var.database.host
  }

  set {
    name  = "externalDatabase.user"
    value = var.database.user
  }

  set {
    name  = "externalDatabase.password"
    value = var.database.password
  }

  set {
    name  = "externalDatabase.database"
    value = var.database.database
  }

  set {
    name  = "auth.adminPassword"
    value = random_password.keycloak_admin_password.result
  }

  set {
    name  = "auth.managementPassword"
    value = random_password.wildfly_management_password.result
  }
}

resource "random_password" "keycloak_admin_password" {
  length  = 32
  special = false
}

resource "random_password" "wildfly_management_password" {
  length  = 32
  special = false
}
