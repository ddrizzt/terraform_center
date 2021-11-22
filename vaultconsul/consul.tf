provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "econsul" {
  name       = "econsul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "0.36.0"
  namespace  = "vc"

  set {
    name  = "server.replicas"
    value = 2
  }

  set {
    name  = "ui.enabled"
    value = true
  }

  set {
    name  = "connectInject.enabled"
    value = true
  }
}

resource "helm_release" "evault" {
  name       = "evault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.17.1"
  namespace  = "vc"
}


