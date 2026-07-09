variable "cluster_credentials_ready" {
	default=""
	description="Opaque value that changes once the cluster kubeconfig is fetched. Threading it through orders the gateway install after the API server is reachable without depending on the whole module."
	type=string
}
variable "cluster_id" {
	description="Resource ID of the AKS cluster the Prometheus data collection rule is associated with."
	type=string
}
variable "deployment_name" {
	type=string
}
variable "envoy_gateway_helm_chart_version" {
	type=string
}
variable "gateway_namespace" {
	default="envoy-gateway-system"
	type=string
}
variable "location" {
	type=string
}
variable "observability_enabled" {
	default=false
	description="Provisions the Azure Monitor workspace and observability workload identities when true."
	type=bool
}
variable "observability_namespace" {
	default="observability"
	type=string
}
variable "oidc_issuer_url" {
	description="The cluster OIDC issuer URL used to federate the observability workload identities."
	type=string
}
variable "resource_group_name" {
	type=string
}
variable "storage_scopes" {
	default=[]
	description="Storage account or container resource IDs the workload identity may read (the overlay bucket analog)."
	type=list(string)
}
variable "tags" {
	default={}
	type=map(string)
}
variable "vnet_cidr" {
	default="10.0.0.0/16"
	type=string
}
