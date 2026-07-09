variable "deployment_name" {
	type=string
}
variable "location" {
	type=string
}
variable "resource_group_name" {
	type=string
}
variable "storage_scopes" {
	default=[]
	description="Storage account or container resource IDs the workload identity may read (the overlay bucket analog)."
	type=list(string)
}
variable "tags" {
	default={}
	type=map(string)
}
