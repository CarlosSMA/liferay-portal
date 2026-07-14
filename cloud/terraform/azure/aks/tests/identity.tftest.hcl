mock_provider "azurerm" {
	mock_resource "azurerm_monitor_data_collection_endpoint" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/liferay-test-prometheus-dce"
		}
	}
	mock_resource "azurerm_monitor_data_collection_rule" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Insights/dataCollectionRules/liferay-test-prometheus-dcr"
		}
	}
	mock_resource "azurerm_monitor_workspace" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Monitor/accounts/liferay-test-prometheus"
		}
	}
	mock_resource "azurerm_nat_gateway" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Network/natGateways/liferay-test-nat"
		}
	}
	mock_resource "azurerm_network_security_group" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Network/networkSecurityGroups/liferay-test-nsg"
		}
	}
	mock_resource "azurerm_public_ip" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Network/publicIPAddresses/liferay-test-nat-ip"
		}
	}
	mock_resource "azurerm_subnet" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Network/virtualNetworks/liferay-test-vnet/subnets/liferay-test-subnet"
		}
	}
	mock_resource "azurerm_user_assigned_identity" {
		defaults={
			client_id="00000000-0000-0000-0000-000000000002"
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/liferay-test-workload-identity"
			principal_id="00000000-0000-0000-0000-000000000001"
		}
	}
	mock_resource "azurerm_virtual_network" {
		defaults={
			id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Network/virtualNetworks/liferay-test-vnet"
		}
	}
}
mock_provider "helm" {}
mock_provider "kubernetes" {}
mock_provider "time" {}
run "should_name_the_workload_identity_from_deployment_name" {
	assert {
		condition=azurerm_user_assigned_identity.workload.name == "liferay-test-workload-identity"
		error_message="The workload identity name must be derived from deployment_name"
	}
	command=plan
}
run "should_create_no_storage_role_assignments_by_default" {
	assert {
		condition=length(azurerm_role_assignment.workload_storage) == 0
		error_message="No storage role assignments must be created when storage_scopes is empty"
	}
	command=plan
}
run "should_create_a_storage_role_assignment_per_scope" {
	assert {
		condition=length(azurerm_role_assignment.workload_storage) == 2
		error_message="One storage role assignment must be created per storage scope"
	}
	assert {
		condition=azurerm_role_assignment.workload_storage["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta"].scope == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta"
		error_message="Each storage role assignment must be scoped to its storage scope"
	}
	assert {
		condition=azurerm_role_assignment.workload_storage["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta"].role_definition_name == "Storage Blob Data Reader"
		error_message="The workload identity must be granted Storage Blob Data Reader on each scope"
	}
	command=plan
	variables {
		storage_scopes=["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytestb"]
	}
}
run "should_deduplicate_storage_scopes" {
	assert {
		condition=length(azurerm_role_assignment.workload_storage) == 1
		error_message="Duplicate storage scopes must collapse to a single role assignment via toset"
	}
	command=plan
	variables {
		storage_scopes=["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.Storage/storageAccounts/liferaytesta"]
	}
}
variables {
	cluster_id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.ContainerService/managedClusters/liferay-test-aks"
	deployment_name="liferay-test"
	envoy_gateway_helm_chart_version="1.6.3"
	location="eastus"
	oidc_issuer_url="https://oidc.example.com/issuer"
	resource_group_name="liferay-test-rg"
}
