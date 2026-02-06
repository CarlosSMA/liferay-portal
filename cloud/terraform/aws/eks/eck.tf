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