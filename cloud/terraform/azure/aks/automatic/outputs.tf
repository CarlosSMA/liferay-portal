output "cluster_name" {
	value=local.cluster_name
}
output "deployment_name" {
	value=var.deployment_name
}
output "gateway_namespace" {
	value=module.gateway.gateway_namespace
}
output "kubelet_identity_object_id" {
	value=data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
output "location" {
	value=var.location
}
output "monitor_workspace_id" {
	value=one(module.observability[*].monitor_workspace_id)
}
output "node_resource_group" {
	value=data.azurerm_kubernetes_cluster.main.node_resource_group
}
output "oidc_issuer_url" {
	value=data.azurerm_kubernetes_cluster.main.oidc_issuer_url
}
output "private_subnet_ids" {
	value=[module.network.subnet_id]
}
output "resource_group_name" {
	value=azurerm_resource_group.main.name
}
output "subnet_id" {
	value=module.network.subnet_id
}
output "workload_identity_client_id" {
	value=module.identity.workload_identity_client_id
}
