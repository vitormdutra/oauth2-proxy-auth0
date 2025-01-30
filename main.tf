resource "helm_release" "oauth2-proxy" {
  name       = "dagster-oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  version    = "7.10.1"

  namespace        = "oauth2-proxy"
  create_namespace = true

  values = [
    templatefile("${path.module}/values.yml", {})
  ]
}
