variable "cluster_id" {
	description="Resource ID of the AKS cluster the Prometheus data collection rule is associated with."
	type=string
}
variable "deployment_name" {
	type=string
}
variable "location" {
	type=string
}
variable "oidc_issuer_url" {
	description="The cluster OIDC issuer URL used to federate the observability workload identities."
	type=string
}
variable "observability_namespace" {
	default="observability"
	type=string
}
variable "resource_group_name" {
	type=string
}
variable "tags" {
	default={}
	type=map(string)
}
