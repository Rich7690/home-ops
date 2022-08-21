//TODO: move to argo
resource "kubernetes_persistent_volume_claim_v1" "vm" {
  metadata {
    name = "vm"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "generic"
    volume_name        = "vm"
    resources {
      requests = {
        "storage" = "16Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "vm" {
  metadata {
    name = "vm"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "generic"
    claim_ref {
      name = "vm"
    }
    capacity = {
      "storage" = "16Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/var/mnt/cache/configs/vm"
        type = ""
      }
    }

  }
}


resource "kubernetes_ingress_v1" "vm" {
  metadata {
    name = "vm-ingress"
    labels = {
      "app" = "vm"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
    }
  }
  spec {
    ingress_class_name = "nginx" //TODO: install nginx ingress controller
    rule {
      host = "vm.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "vm-victoria-metrics-single-server"
              port {
                number = 8428
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [var.domain_name, "*.${var.domain_name}"]
      secret_name = "prod-cert" //TODO: create secret with TLS certs
    }
  }

}
