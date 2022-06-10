locals {
  ingress_nginx = {
    chart_version = "4.1.3"
  }
}

resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = local.ingress_nginx.chart_version

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ip
  }

  set {
    name  = "controller.nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = var.node_pool
  }
}
