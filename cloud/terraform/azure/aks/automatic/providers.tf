provider "azapi" {}
provider "azurerm" {
	features {}
}

# AKS Automatic is created through the azapi provider (azurerm has no "Automatic" SKU), so
# connection details come from the azurerm_kubernetes_cluster data source rather than the
# resource. The API server is private; the helm and kubernetes providers reach it with the
# cluster CA and host plus a kubelogin exec token (the AWS EKS `aws eks get-token` pattern).
# The runner needs line-of-sight to the private endpoint and `az` + `kubelogin` installed.
# 6dae42f8-4368-4678-94ff-3960e28e3630 is the well-known AKS AAD server app ID.

provider "helm" {
	kubernetes={
		cluster_ca_certificate=base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
		exec={
			api_version="client.authentication.k8s.io/v1beta1"
			args=["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
			command="kubelogin"
		}
		host=data.azurerm_kubernetes_cluster.main.kube_config[0].host
	}
}
provider "kubernetes" {
	cluster_ca_certificate=base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
	exec {
		api_version="client.authentication.k8s.io/v1beta1"
		args=["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
		command="kubelogin"
	}
	host=data.azurerm_kubernetes_cluster.main.kube_config[0].host
}
terraform {
	backend "azurerm" {}
	required_providers {
		azapi={
			source="Azure/azapi"
			version="~> 2.8"
		}
		azurerm={
			source="hashicorp/azurerm"
			version="~> 4.0"
		}
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		kubernetes={
			source="hashicorp/kubernetes"
			version="~> 2.36"
		}
		null={
			source="hashicorp/null"
			version="~> 3.0"
		}
		random={
			source="hashicorp/random"
			version="~> 3.8"
		}
		time={
			source="hashicorp/time"
			version="~> 0.12"
		}
	}
	required_version=">= 1.10.0"
}
