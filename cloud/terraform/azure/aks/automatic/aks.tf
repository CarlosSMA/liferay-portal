# AKS Automatic is a distinct SKU that azurerm cannot create, so it is provisioned with the
# azapi provider. Automatic enforces Node Auto Provisioning, the Cilium/overlay dataplane,
# Workload Identity + OIDC, Azure RBAC, disabled local accounts, and managed
# Prometheus/Container Insights, so the body stays minimal. schema_validation_enabled is off
# because several Automatic-managed properties are not in the azapi schema.
#
# BYO networking under Automatic is constrained (see LCD-52471 blockers): the vnetSubnetID
# and userAssignedNATGateway outbound below express the same intent as the standard flavor,
# but the first apply must confirm Automatic accepts them; otherwise drop to managed
# networking by removing networkProfile and vnetSubnetID.

resource "azapi_resource" "main" {
	body={
		properties={
			agentPoolProfiles=[
				{
					count=var.system_node_count
					mode="System"
					name="systempool"
					vmSize=var.system_node_vm_size
					vnetSubnetID=module.network.subnet_id
				}
			]
			apiServerAccessProfile={
				enablePrivateCluster=var.private_cluster
			}
			dnsPrefix=var.deployment_name
			networkProfile={
				outboundType="userAssignedNATGateway"
			}
			nodeResourceGroup="${var.deployment_name}-nrg"
		}
		sku={
			name="Automatic"
			tier="Standard"
		}
	}
	depends_on=[
		module.network,
	]
	identity {
		type="SystemAssigned"
	}
	location=var.location
	name=local.cluster_name
	parent_id=azurerm_resource_group.main.id
	response_export_values=["properties.oidcIssuerProfile.issuerURL"]
	schema_validation_enabled=false
	tags=local.tags
	type="Microsoft.ContainerService/managedClusters@2025-10-01"
}
resource "azurerm_federated_identity_credential" "liferay" {
	audience=["api://AzureADTokenExchange"]
	issuer=data.azurerm_kubernetes_cluster.main.oidc_issuer_url
	name="${var.deployment_name}-liferay-default"
	parent_id=module.identity.workload_identity_id
	resource_group_name=azurerm_resource_group.main.name
	subject="system:serviceaccount:${var.deployment_namespace}:liferay-default"
}
resource "azurerm_role_assignment" "acr_pull" {
	for_each=var.container_registries
	principal_id=data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
	role_definition_name="AcrPull"
	scope=each.value.id
}
resource "azurerm_role_assignment" "cluster_network_contributor" {
	principal_id=azapi_resource.main.identity[0].principal_id
	role_definition_name="Network Contributor"
	scope=module.network.vnet_id
}
