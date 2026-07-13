locals {

	# The workload identities that back the observability service accounts. Mirrors
	# the alloy/grafana IRSA roles in the AWS EKS module: alloy remote-writes metrics,
	# grafana queries them. On Azure both talk to the Azure Monitor workspace. When
	# observability is disabled the map is empty, so none of the identities are created.

	observability_service_accounts=var.observability_enabled ? {
		grafana={
			role="Monitoring Data Reader"
			service_account="grafana"
		}
		liferay-alloy={
			role="Monitoring Metrics Publisher"
			service_account="liferay-alloy"
		}
	} : {}
}
resource "azurerm_federated_identity_credential" "observability" {
	audience=["api://AzureADTokenExchange"]
	for_each=local.observability_service_accounts
	issuer=var.oidc_issuer_url
	name="${var.deployment_name}-${each.key}"
	parent_id=azurerm_user_assigned_identity.observability[each.key].id
	resource_group_name=var.resource_group_name
	subject="system:serviceaccount:${var.observability_namespace}:${each.value.service_account}"
}
resource "azurerm_monitor_data_collection_endpoint" "prometheus" {
	count=var.observability_enabled ? 1 : 0
	kind="Linux"
	location=var.region
	name="${var.deployment_name}-prometheus-dce"
	resource_group_name=var.resource_group_name
	tags=var.tags
}
resource "azurerm_monitor_data_collection_rule" "prometheus" {
	count=var.observability_enabled ? 1 : 0
	data_collection_endpoint_id=azurerm_monitor_data_collection_endpoint.prometheus[0].id
	data_flow {
		destinations=["MonitoringAccount"]
		streams=["Microsoft-PrometheusMetrics"]
	}
	data_sources {
		prometheus_forwarder {
			name="PrometheusDataSource"
			streams=["Microsoft-PrometheusMetrics"]
		}
	}
	destinations {
		monitor_account {
			monitor_account_id=azurerm_monitor_workspace.prometheus[0].id
			name="MonitoringAccount"
		}
	}
	kind="Linux"
	location=var.region
	name="${var.deployment_name}-prometheus-dcr"
	resource_group_name=var.resource_group_name
	tags=var.tags
}
resource "azurerm_monitor_data_collection_rule_association" "prometheus" {
	count=var.observability_enabled ? 1 : 0
	data_collection_rule_id=azurerm_monitor_data_collection_rule.prometheus[0].id
	name="${var.deployment_name}-prometheus-dcra"
	target_resource_id=var.cluster_id
}
resource "azurerm_monitor_workspace" "prometheus" {
	count=var.observability_enabled ? 1 : 0
	location=var.region
	name="${var.deployment_name}-prometheus"
	resource_group_name=var.resource_group_name
	tags=var.tags
}
resource "azurerm_role_assignment" "observability" {
	for_each=local.observability_service_accounts
	principal_id=azurerm_user_assigned_identity.observability[each.key].principal_id
	role_definition_name=each.value.role
	scope=azurerm_monitor_workspace.prometheus[0].id
}
resource "azurerm_user_assigned_identity" "observability" {
	for_each=local.observability_service_accounts
	location=var.region
	name="${var.deployment_name}-${each.key}"
	resource_group_name=var.resource_group_name
	tags=var.tags
}
