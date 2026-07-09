locals {
	cluster_name="${var.deployment_name}-aks"
	tags={
		DeploymentName=var.deployment_name
		managed_by="terraform"
	}
}
