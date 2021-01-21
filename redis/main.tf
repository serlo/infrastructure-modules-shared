resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
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
    name  = "master.resources.limits.cpu"
    value = "350m"
  }

  set {
    name  = "master.resources.limits.memory"
    value = "750Mi"
  }

  set {
    name  = "master.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "master.resources.requests.memory"
    value = "500Mi"
  }
}
