provider "helm" {
  kubernetes {
    config_path    = "./kubeconfig"
    config_context = "admin@home-cluster"
  }
}
