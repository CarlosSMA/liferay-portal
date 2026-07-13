output "cluster_name" {
	value=azurerm_kubernetes_cluster.main.name
}
output "deployment_name" {
	value=var.deployment_name
}
output "gateway_namespace" {
	value=module.shared.gateway_namespace
}
output "kubelet_identity_object_id" {
	value=azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
output "monitor_workspace_id" {
	value=module.shared.monitor_workspace_id
}
output "node_resource_group" {
	value=azurerm_kubernetes_cluster.main.node_resource_group
}
output "oidc_issuer_url" {
	value=azurerm_kubernetes_cluster.main.oidc_issuer_url
}
output "private_subnet_ids" {
	value=[module.shared.subnet_id]
}
output "region" {
	value=var.region
}
output "resource_group_name" {
	value=azurerm_resource_group.main.name
}
output "subnet_id" {
	value=module.shared.subnet_id
}
output "workload_identity_client_id" {
	value=module.shared.workload_identity_client_id
}
