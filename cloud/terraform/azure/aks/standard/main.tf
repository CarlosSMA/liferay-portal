module "gateway" {
	depends_on=[
		terraform_data.get_credentials,
	]
	envoy_gateway_helm_chart_version=var.envoy_gateway_helm_chart_version
	gateway_namespace=var.gateway_namespace
	source="../modules/gateway"
}
module "identity" {
	deployment_name=var.deployment_name
	location=var.location
	resource_group_name=azurerm_resource_group.main.name
	source="../modules/identity"
	storage_scopes=var.overlay_storage_account_ids
	tags=local.tags
}
module "network" {
	deployment_name=var.deployment_name
	location=var.location
	resource_group_name=azurerm_resource_group.main.name
	source="../modules/network"
	tags=local.tags
	vnet_cidr=var.vnet_cidr
}
module "observability" {
	cluster_id=azurerm_kubernetes_cluster.main.id
	count=var.observability_config.enabled ? 1 : 0
	deployment_name=var.deployment_name
	location=var.location
	oidc_issuer_url=azurerm_kubernetes_cluster.main.oidc_issuer_url
	observability_namespace=var.observability_config.namespace
	resource_group_name=azurerm_resource_group.main.name
	source="../modules/observability"
	tags=local.tags
}
resource "azurerm_resource_group" "main" {
	location=var.location
	name="${var.deployment_name}-rg"
	tags=local.tags
}
resource "azurerm_role_assignment" "cluster_network_contributor" {
	principal_id=azurerm_user_assigned_identity.cluster.principal_id
	role_definition_name="Network Contributor"
	scope=module.network.vnet_id
}
resource "azurerm_user_assigned_identity" "cluster" {
	location=var.location
	name="${var.deployment_name}-cluster-identity"
	resource_group_name=azurerm_resource_group.main.name
	tags=local.tags
}
resource "terraform_data" "get_credentials" {
	depends_on=[
		azurerm_kubernetes_cluster.main,
	]
	provisioner "local-exec" {
		command="az aks get-credentials --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing --resource-group ${azurerm_resource_group.main.name}"
	}
	triggers_replace=[
		azurerm_kubernetes_cluster.main.id,
	]
}
