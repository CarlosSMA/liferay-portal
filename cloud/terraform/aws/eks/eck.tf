resource "helm_release" "eck" {
  repository="https://helm.elastic.co"
  name="eck-operator"
  chart="eck-operator"
  upgrade_install=true
  depends_on=[
    module.eks,
  ]
  version="3.2.0"
  namespace="elastic-system"
  create_namespace=true
}

resource "kubernetes_manifest" "elasticsearch" {
  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind"       = "Elasticsearch"
    "metadata" = {
      "name"      = "elasticsearch"
      "namespace" = "elastic-system"
    }
    "spec" = {
      "version" = "8.12.0"
      "nodeSets" = [
        {
          "name"  = "default"
          "count" = 1
          "config" = {
            "node.store.allow_mmap" = false
          }
        }
      ]
    }
  }
}