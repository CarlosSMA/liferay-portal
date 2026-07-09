data "azurerm_kubernetes_cluster" "main" {
	depends_on=[
		azapi_resource.main,
	]
	name=local.cluster_name
	resource_group_name=azurerm_resource_group.main.name
}
