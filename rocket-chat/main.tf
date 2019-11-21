resource "helm_release" "rocket-chat_deployment" {
  name       = "rocket-chat"
  chart      = "stable/rocketchat"
  repository = data.helm_repository.stable.metadata[0].name
  namespace  = var.namespace

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "host"
    value = var.host
  }

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "minAvailable"
    value = "1"
  }

  set {
    name  = "mongodb.mongodbPassword"
    value = random_password.mongodb_password.result
  }

  set {
    name  = "mongodb.mongodbRootPassword"
    value = random_password.mongodb_root_password.result
  }

  set {
    name  = "mongodb.mongodbUsername"
    value = "rocket-chat"
  }

  set {
    name  = "mongodb.mongodbDatabase"
    value = "rocket-chat-db"
  }

  set {
    name  = "mongodb.replicaSet.enabled"
    value = "true"
  }

  set {
    name  = "mongodb.replicaSet.replicas.secondary"
    value = "1"
  }

  set {
    name  = "mongodb.replicaSet.pdb.minAvailable.secondary"
    value = "1"
  }

  set {
    name  = "mongodb.replicaSet.replicas.arbiter"
    value = "1"
  }

  set {
    name  = "mongodb.replicaSet.pdb.minAvailable.arbiter"
    value = "1"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    name  = "ingress.path"
    value = "/"
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}

resource "random_password" "mongodb_password" {
  length  = 32
  special = false
}

resource "random_password" "mongodb_root_password" {
  length  = 32
  special = false
}

provider "helm" {
  version = "~> 0.10"
}

provider "random" {
  version = "~> 2.2"
}
