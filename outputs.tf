output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.demo.name
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.demo.name
}

output "frontend_subnet_id" {
  description = "The ID of the frontend subnet."
  value       = azurerm_subnet.demo["frontend"].id
}

output "backend_subnet_id" {
  description = "The ID of the backend subnet."
  value       = azurerm_subnet.demo["backend"].id
}

output "database_subnet_id" {
  description = "The ID of the database subnet."
  value       = azurerm_subnet.demo["db"].id
}

output "app_gateway_subnet_id" {
  description = "The ID of the Application Gateway subnet."
  value       = azurerm_subnet.demo["appgw"].id
}

output "app_gateway_public_ip" {
  description = "The public IP address of the Application Gateway."
  value       =  azurerm_public_ip.app_gateway_public_ip.ip_address
}

output "frontend_nsg_id" {
  description = "The ID of the frontend Network Security Group."
  value       = azurerm_network_security_group.demo["frontend"].id
}

output "backend_nsg_id" {
  description = "The ID of the backend Network Security Group."
  value       = azurerm_network_security_group.demo["backend"].id
}

output "database_nsg_id" {
  description = "The ID of the database Network Security Group."
  value       = azurerm_network_security_group.demo["db"].id
}

output "app_gateway_nsg_id" {
  description = "The ID of the Application Gateway Network Security Group."
  value       = azurerm_network_security_group.demo["appgw"].id
}
