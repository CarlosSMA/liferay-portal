resource "kubernetes_manifest" "elasticsearch" {
  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind"       = "Elasticsearch"
    "metadata" = {
      "name"      = "elasticsearchv2"
      "namespace" = "elastic-system"
    }
    "spec" = {
      "version" = "8.12.0"
      "http" = {
        "tls" = {
          "selfSignedCertificate" = {
            "disabled" = true
          }
        }
      }
      "nodeSets" = [
        {
          "name"  = "default"
          "count" = 1
          "config" = {
            "node.store.allow_mmap" = false
          }
          "volumeClaimTemplates" = [
            {
              "metadata" = {
                "name" = "elasticsearch-data"
              }
              "spec" = {
                "accessModes" = ["ReadWriteOnce"]
                "resources" = {
                  "requests" = {
                    "storage" = "10Gi"
                  }
                }
              }
            }
          ]
        }
      ]
    }
  }
}