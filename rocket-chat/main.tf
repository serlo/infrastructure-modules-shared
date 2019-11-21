resource "helm_release" "rocket-chat_deployment" {
  name       = "rocket-chat"
  chart      = "stable/rocketchat"
  repository = data.helm_repository.stable.metadata[0].name
  namespace  = var.namespace


  set {
    name  = "image.tag"
    value = "2.2.0"
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
    value = "password"
  }

  set {
    name  = "mongodb.mongodbRootPassword"
    value = "password"
  }

  set {
    name  = "mongodb.mongodbUsername"
    value = "username"
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

provider "helm" {
  version = "~> 0.10"
}
