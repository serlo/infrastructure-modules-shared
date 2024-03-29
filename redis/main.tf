resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
  chart      = "redis"
  version    = var.chart_version
  namespace  = var.namespace
  atomic     = true

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "master.nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = var.node_pool
  }

  set {
    name  = "replica.nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = var.node_pool
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
    value = "1Gi"
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
