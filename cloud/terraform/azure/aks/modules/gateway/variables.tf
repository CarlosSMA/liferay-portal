variable "envoy_gateway_helm_chart_version" {
	type=string
}
variable "gateway_namespace" {
	default="envoy-gateway-system"
	type=string
}
