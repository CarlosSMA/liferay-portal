variable "deployment_name" {
	type=string
}
variable "location" {
	type=string
}
variable "resource_group_name" {
	type=string
}
variable "tags" {
	default={}
	type=map(string)
}
variable "vnet_cidr" {
	default="10.0.0.0/16"
	type=string
}
