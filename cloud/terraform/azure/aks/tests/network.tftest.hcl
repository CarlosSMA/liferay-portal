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
run "should_compute_the_subnet_cidr" {
	assert {
		condition=local.subnet_cidr == "10.0.0.0/20"
		error_message="The subnet CIDR must be cidrsubnet(vnet_cidr, 4, 0)"
	}
	assert {
		condition=azurerm_subnet.main.address_prefixes[0] == "10.0.0.0/20"
		error_message="The subnet address prefix must use the computed subnet CIDR"
	}
	command=plan
}
run "should_shift_the_subnet_cidr_when_vnet_cidr_changes" {
	assert {
		condition=local.subnet_cidr == "172.16.0.0/20"
		error_message="A custom vnet_cidr must drive the computed subnet CIDR"
	}
	assert {
		condition=contains(azurerm_virtual_network.main.address_space, "172.16.0.0/16")
		error_message="The virtual network address space must follow vnet_cidr"
	}
	command=plan
	variables {
		vnet_cidr="172.16.0.0/16"
	}
}
run "should_name_network_resources_from_deployment_name" {
	assert {
		condition=azurerm_virtual_network.main.name == "liferay-test-vnet"
		error_message="The virtual network name must be derived from deployment_name"
	}
	assert {
		condition=azurerm_subnet.main.name == "liferay-test-subnet"
		error_message="The subnet name must be derived from deployment_name"
	}
	assert {
		condition=azurerm_nat_gateway.main.name == "liferay-test-nat" && azurerm_public_ip.nat.name == "liferay-test-nat-ip"
		error_message="The NAT gateway and its public IP names must be derived from deployment_name"
	}
	assert {
		condition=azurerm_network_security_group.main.name == "liferay-test-nsg"
		error_message="The network security group name must be derived from deployment_name"
	}
	command=plan
}
run "should_configure_the_envoy_ingress_rule" {
	assert {
		condition=azurerm_network_security_rule.envoy_ingress.destination_port_ranges == toset(["10080", "10443"])
		error_message="The Envoy ingress rule must open ports 10080 and 10443"
	}
	assert {
		condition=azurerm_network_security_rule.envoy_ingress.source_address_prefix == "10.0.0.0/16"
		error_message="The Envoy ingress rule must be scoped to the VNet CIDR"
	}
	assert {
		condition=azurerm_network_security_rule.envoy_ingress.access == "Allow" && azurerm_network_security_rule.envoy_ingress.direction == "Inbound"
		error_message="The Envoy ingress rule must allow inbound traffic"
	}
	assert {
		condition=azurerm_network_security_rule.envoy_ingress.protocol == "Tcp" && azurerm_network_security_rule.envoy_ingress.priority == 1000
		error_message="The Envoy ingress rule must be a TCP rule at priority 1000"
	}
	command=plan
}
variables {
	cluster_id="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/liferay-test-rg/providers/Microsoft.ContainerService/managedClusters/liferay-test-aks"
	deployment_name="liferay-test"
	envoy_gateway_helm_chart_version="1.6.3"
	location="eastus"
	oidc_issuer_url="https://oidc.example.com/issuer"
	resource_group_name="liferay-test-rg"
}
