module "shared" {
	cluster_credentials_ready=terraform_data.get_credentials.id
	cluster_id=azurerm_kubernetes_cluster.main.id
	deployment_name=var.deployment_name
	envoy_gateway_helm_chart_version=var.envoy_gateway_helm_chart_version
	gateway_namespace=var.gateway_namespace
	observability_enabled=var.observability_config.enabled
	observability_namespace=var.observability_config.namespace
	oidc_issuer_url=azurerm_kubernetes_cluster.main.oidc_issuer_url
	region=var.region
	resource_group_name=azurerm_resource_group.main.name
	source="../modules/shared"
	storage_scopes=var.overlay_storage_account_ids
	tags=local.tags
	vpc_cidr=var.vpc_cidr
}
resource "azurerm_resource_group" "main" {
	location=var.region
	name="${var.deployment_name}-rg"
	tags=local.tags
}
resource "azurerm_role_assignment" "cluster_network_contributor" {
	principal_id=azurerm_user_assigned_identity.cluster.principal_id
	role_definition_name="Network Contributor"
	scope=module.shared.vnet_id
}
resource "azurerm_user_assigned_identity" "cluster" {
	location=var.region
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
