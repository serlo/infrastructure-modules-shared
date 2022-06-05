resource "kubernetes_secret" "ingress_nginx_tls_secret" {
  metadata {
    name      = "ingress-nginx-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = module.cert.crt
    "tls.key" = module.cert.key
  }

  type = "kubernetes.io/tls"
}

module "cert" {
  source = "../tls-self-signed-cert"
  domain = var.domain
}

resource "kubernetes_service" "ingress_nginx_service" {
  metadata {
    //we can not use our naming pattern "ingress-nginx-service" here because of warnings in log file
    name      = "ingress-nginx"
    namespace = var.namespace
  }

  spec {
    load_balancer_ip = var.ip

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    selector = {
      app = kubernetes_deployment.nginx_ingress_deployment.metadata[0].labels.app
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_config_map" "nginx_configuration" {
  metadata {
    name      = "nginx-configuration"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map" "tcp_services" {
  metadata {
    name      = "tcp-services"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map" "udp_services" {
  metadata {
    name      = "udp-services"
    namespace = var.namespace
  }
}

resource "kubernetes_service_account" "nginx_ingress_serviceaccount" {
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = var.namespace
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "nginx_ingress_clusterrole" {
  metadata {
    name = "nginx-ingress-clusterrole"
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
  }
}

resource "kubernetes_role" "nginx_ingress_role" {
  metadata {
    name      = "nginx-ingress-role"
    namespace = var.namespace
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "namespaces"]
  }

  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["endpoints"]
  }
}

resource "kubernetes_role_binding" "nginx_ingress_role_nisa_binding" {
  metadata {
    name      = "nginx-ingress-role-nisa-binding"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx_ingress_serviceaccount.metadata[0].name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "nginx-ingress-role"
  }
}

resource "kubernetes_cluster_role_binding" "nginx_ingress_clusterrole_nisa_binding" {
  metadata {
    name = "nginx-ingress-clusterrole-nisa-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx_ingress_serviceaccount.metadata[0].name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nginx-ingress-clusterrole"
  }
}

resource "kubernetes_deployment" "nginx_ingress_deployment" {
  metadata {
    name      = "nginx-ingress-app"
    namespace = var.namespace

    labels = {
      app = "ingress-nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ingress-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "ingress-nginx"
        }

        annotations = {
          "prometheus.io/port"   = "10254"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        service_account_name = kubernetes_service_account.nginx_ingress_serviceaccount.metadata[0].name

        container {
          name  = "nginx-ingress-container"
          image = var.nginx_image
          args  = ["/nginx-ingress-controller", "--configmap=$(POD_NAMESPACE)/nginx-configuration", "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services", "--udp-services-configmap=$(POD_NAMESPACE)/udp-services", "--publish-service=$(POD_NAMESPACE)/ingress-nginx", "--annotations-prefix=nginx.ingress.kubernetes.io", "--default-ssl-certificate=${var.namespace}/ingress-nginx-tls-secret"]

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "https"
            container_port = 443
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 10
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            timeout_seconds   = 10
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
          }

          security_context {
            run_as_user = 33
            //allow_privilege_escalation = true
          }
        }
      }
    }
  }
}
