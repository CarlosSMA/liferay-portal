resource "azurerm_role_assignment" "workload_storage" {
	for_each=toset(var.storage_scopes)
	principal_id=azurerm_user_assigned_identity.workload.principal_id
	role_definition_name="Storage Blob Data Reader"
	scope=each.value
}
resource "azurerm_user_assigned_identity" "workload" {
	location=var.location
	name="${var.deployment_name}-workload-identity"
	resource_group_name=var.resource_group_name
	tags=var.tags
}
