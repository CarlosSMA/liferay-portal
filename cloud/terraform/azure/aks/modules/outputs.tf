output "gateway_namespace" {
	value=var.gateway_namespace
}
output "monitor_workspace_id" {
	value=one(azurerm_monitor_workspace.prometheus[*].id)
}
output "subnet_id" {

	# Depend on the NAT gateway and network security group associations so consumers that
	# wire this subnet into a cluster wait for outbound and ingress rules to be in place.

	depends_on=[
		azurerm_subnet_nat_gateway_association.main,
		azurerm_subnet_network_security_group_association.main,
	]
	value=azurerm_subnet.main.id
}
output "vnet_id" {
	value=azurerm_virtual_network.main.id
}
output "workload_identity_client_id" {
	value=azurerm_user_assigned_identity.workload.client_id
}
output "workload_identity_id" {
	value=azurerm_user_assigned_identity.workload.id
}
