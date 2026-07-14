locals {
	resource_group_name=var.deployment_name
	storage_scopes=[]
	tags=[var.deployment_name, var.region]
}