resource "helm_release" "redis" {
  name       = "redis"
  chart      = "stable/redis"
  repository = data.helm_repository.stable.metadata[0].name
  namespace  = var.namespace

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "cluster.enabled"
    value = true
  }

  set {
    name  = "cluster.slaveCount"
    value = 0
  }

  set {
    name  = "usePassword"
    value = false
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}
