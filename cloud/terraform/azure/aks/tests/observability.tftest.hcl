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
run "should_disable_observability_by_default" {
	assert {
		condition=length(azurerm_monitor_workspace.prometheus) == 0
		error_message="No Prometheus workspace must be created when observability is disabled"
	}
	assert {
		condition=length(azurerm_monitor_data_collection_endpoint.prometheus) == 0 && length(azurerm_monitor_data_collection_rule.prometheus) == 0 && length(azurerm_monitor_data_collection_rule_association.prometheus) == 0
		error_message="No Prometheus data collection resources must be created when observability is disabled"
	}
	assert {
		condition=length(azurerm_user_assigned_identity.observability) == 0 && length(azurerm_federated_identity_credential.observability) == 0 && length(azurerm_role_assignment.observability) == 0
		error_message="No observability identities, federated credentials, or role assignments must be created when observability is disabled"
	}
	assert {
		condition=output.monitor_workspace_id == null
		error_message="The monitor_workspace_id output must be null when observability is disabled"
	}
	command=plan
}
run "should_create_observability_resources_when_enabled" {
	assert {
		condition=length(azurerm_monitor_workspace.prometheus) == 1 && length(azurerm_monitor_data_collection_endpoint.prometheus) == 1
		error_message="A Prometheus workspace and data collection endpoint must be created when observability is enabled"
	}
	assert {
		condition=length(azurerm_monitor_data_collection_rule.prometheus) == 1 && length(azurerm_monitor_data_collection_rule_association.prometheus) == 1
		error_message="A Prometheus data collection rule and association must be created when observability is enabled"
	}
	assert {
		condition=azurerm_monitor_workspace.prometheus[0].name == "liferay-test-prometheus"
		error_message="The Prometheus workspace name must be derived from deployment_name"
	}
	assert {
		condition=azurerm_monitor_data_collection_rule_association.prometheus[0].target_resource_id == var.cluster_id
		error_message="The data collection rule association must target the AKS cluster"
	}
	command=plan
	variables {
		observability_enabled=true
	}
}
run "should_create_two_observability_identities_when_enabled" {
	assert {
		condition=length(azurerm_user_assigned_identity.observability) == 2
		error_message="Two observability identities must be created when observability is enabled"
	}
	assert {
		condition=azurerm_user_assigned_identity.observability["grafana"].name == "liferay-test-grafana"
		error_message="The grafana observability identity name must be derived from deployment_name"
	}
	assert {
		condition=azurerm_user_assigned_identity.observability["liferay-alloy"].name == "liferay-test-liferay-alloy"
		error_message="The liferay-alloy observability identity name must be derived from deployment_name"
	}
	command=plan
	variables {
		observability_enabled=true
	}
}
run "should_assign_the_correct_role_per_service_account" {
	assert {
		condition=azurerm_role_assignment.observability["grafana"].role_definition_name == "Monitoring Data Reader"
		error_message="The grafana identity must be granted Monitoring Data Reader"
	}
	assert {
		condition=azurerm_role_assignment.observability["liferay-alloy"].role_definition_name == "Monitoring Metrics Publisher"
		error_message="The liferay-alloy identity must be granted Monitoring Metrics Publisher"
	}
	command=plan
	variables {
		observability_enabled=true
	}
}
run "should_build_the_federated_identity_subject" {
	assert {
		condition=azurerm_federated_identity_credential.observability["grafana"].subject == "system:serviceaccount:obs-ns:grafana"
		error_message="The federated identity subject must embed the observability namespace and service account"
	}
	assert {
		condition=azurerm_federated_identity_credential.observability["grafana"].issuer == var.oidc_issuer_url
		error_message="The federated identity must be issued by the cluster OIDC issuer"
	}
	assert {
		condition=azurerm_federated_identity_credential.observability["grafana"].audience == tolist(["api://AzureADTokenExchange"])
		error_message="The federated identity audience must be the Azure AD token exchange audience"
	}
	command=plan
	variables {
		observability_enabled=true
		observability_namespace="obs-ns"
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
