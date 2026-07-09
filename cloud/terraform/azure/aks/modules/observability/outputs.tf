output "monitor_workspace_id" {
	value=azurerm_monitor_workspace.prometheus.id
}
output "prometheus_query_endpoint" {
	value=azurerm_monitor_workspace.prometheus.query_endpoint
}
output "workload_identity_client_ids" {
	value={
		for key, identity in azurerm_user_assigned_identity.observability : key => identity.client_id
	}
}
