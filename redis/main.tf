resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "redis"
  version    = var.chart_version
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

  set {
    name = "master.resources.limits.cpu"
    value = "200m"
  }

  set {
    name = "master.resources.limits.memory"
    value = "200Mi"
  }

  set {
    name = "master.resources.requests.cpu"
    value = "100m"
  }

  set {
    name = "master.resources.requests.memory"
    value = "100Mi"
  }
}
