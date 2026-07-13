variable "api_authorized_ip_ranges" {
	default=[]
	description="CIDRs allowed to reach the API server. Only applied when private_cluster is false."
	type=list(string)
}
variable "container_registries" {
	default={}
	description="Azure Container Registries the kubelet identity may pull from (the ECR analog)."
	type=map(object({
		id=string
	}))
}
variable "deployment_name" {
	type=string
	validation {
		condition=can(regex("^[a-z][a-z0-9-]{2,23}$", var.deployment_name))
		error_message="The variable \"deployment_name\" must be 3-24 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
	}
}
variable "deployment_namespace" {
	default="liferay-system"
	description="Kubernetes namespace whose liferay-default service account is federated to the workload identity."
	type=string
	validation {
		condition=can(regex("^[a-z0-9-]*$", var.deployment_namespace))
		error_message="The deployment_namespace must contain only lowercase letters, numbers, and hyphens."
	}
}
variable "dns_service_ip" {
	default="10.245.0.10"
	type=string
}
variable "envoy_gateway_helm_chart_version" {
	type=string
}
variable "gateway_namespace" {
	default="envoy-gateway-system"
	type=string
}
variable "max_node_count" {
	default=4
	type=number
}
variable "min_node_count" {
	default=1
	type=number
}
variable "observability_config" {
	default={}
	type=object({
		enabled=optional(bool, false)
		namespace=optional(string, "observability")
	})
}
variable "overlay_storage_account_ids" {
	default=[]
	description="Storage account or container resource IDs the workload identity may read (the S3 overlay analog)."
	type=list(string)
}
variable "pod_cidr" {
	default="10.244.0.0/16"
	description="Overlay pod CIDR. Must not overlap vpc_cidr or service_cidr."
	type=string
}
variable "private_cluster" {
	default=true
	type=bool
}
variable "region" {
	type=string
}
variable "service_cidr" {
	default="10.245.0.0/16"
	description="Service CIDR. Must not overlap vpc_cidr or pod_cidr."
	type=string
}
variable "machine_type" {
	default="Standard_D4s_v5"
	type=string
}
variable "vpc_cidr" {
	default="10.0.0.0/16"
	type=string
}
