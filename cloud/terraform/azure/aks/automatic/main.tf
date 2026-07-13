module "shared" {
	cluster_credentials_ready=terraform_data.get_credentials.id
	cluster_id=azapi_resource.main.id
	deployment_name=var.deployment_name
	envoy_gateway_helm_chart_version=var.envoy_gateway_helm_chart_version
	gateway_namespace=var.gateway_namespace
	observability_enabled=var.observability_config.enabled
	observability_namespace=var.observability_config.namespace
	oidc_issuer_url=data.azurerm_kubernetes_cluster.main.oidc_issuer_url
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
resource "terraform_data" "get_credentials" {
	depends_on=[
		azapi_resource.main,
	]
	provisioner "local-exec" {
		command="az aks get-credentials --name ${local.cluster_name} --overwrite-existing --resource-group ${azurerm_resource_group.main.name}"
	}
	triggers_replace=[
		azapi_resource.main.id,
	]
}
