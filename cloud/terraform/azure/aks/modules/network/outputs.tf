output "nat_gateway_id" {
	value=azurerm_nat_gateway.main.id
}
output "network_security_group_id" {
	value=azurerm_network_security_group.main.id
}
output "subnet_cidr" {
	value=local.subnet_cidr
}
output "subnet_id" {
	value=azurerm_subnet.main.id
}
output "subnet_name" {
	value=azurerm_subnet.main.name
}
output "vnet_id" {
	value=azurerm_virtual_network.main.id
}
output "vnet_name" {
	value=azurerm_virtual_network.main.name
}
