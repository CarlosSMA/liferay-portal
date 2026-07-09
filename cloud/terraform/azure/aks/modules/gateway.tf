resource "helm_release" "envoy_gateway" {
	chart="gateway-helm"
	create_namespace=true
	depends_on=[
		time_sleep.cluster_ready_buffer,
	]
	name="envoy-gateway"
	namespace=var.gateway_namespace
	repository="oci://docker.io/envoyproxy"
	values=[
		yamlencode(
			{
				config={
					envoyGateway={
						extensionApis={
							enableBackend=false
						}
					}
				}
				deployment={
					replicas=2
				}
				podDisruptionBudget={
					maxUnavailable=1
				}
			}),
	]
	version="v${var.envoy_gateway_helm_chart_version}"
}
resource "kubernetes_pod_disruption_budget_v1" "envoy_proxy_pdb" {
	depends_on=[
		helm_release.envoy_gateway,
	]
	metadata {
		name="envoy-proxy-pdb"
		namespace=var.gateway_namespace
	}
	spec {
		max_unavailable="1"
		selector {
			match_labels={
				"app.kubernetes.io/component"="proxy"
				"app.kubernetes.io/name"="envoy"
			}
		}
	}
}
resource "time_sleep" "cluster_ready_buffer" {
	create_duration="30s"
	triggers={
		cluster_credentials_ready=var.cluster_credentials_ready
	}
}
