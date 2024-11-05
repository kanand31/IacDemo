resource "azurerm_resource_group" "demo" {
    name = "katestlearning"
    location = var.vnet_location
}
resource "azurerm_virtual_network" "demo" {
    name = "demo-3tiervnet"
    address_space = var.cidr_block
    location = var.vnet_location
    resource_group_name = azurerm_resource_group.demo.name
}
resource "azurerm_subnet" "demo" {
  for_each             = var.subnets
  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = [each.value.address_prefix]
}


resource "azurerm_network_security_group" "demo" {
  for_each            = var.network_security_groups
  name                = each.key
  location            = var.vnet_location
  resource_group_name = azurerm_resource_group.demo.name

  # Dynamic block to create multiple security rules for each NSG
  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
# Associating each NSG with its respective subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_associations" {
  for_each = azurerm_subnet.demo
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.demo[each.key].id
}
# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "appGatewayPublicIP"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.vnet_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "appGateway"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.vnet_location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gatewayIpConfig"
    subnet_id = azurerm_subnet.demo["appgw"].id
  }

  frontend_ip_configuration {
    name                 = "publicFrontendIpConfig"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

 /* frontend_port {
    name = "httpsPort"
    port = 443
  }
*/
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "publicFrontendIpConfig"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

 /* http_listener {
    name                           = "httpsListener"
    frontend_ip_configuration_name = "publicFrontendIpConfig"
    frontend_port_name             = "httpsPort"
    protocol                       = "Https"
  }
  */

  backend_address_pool {
    name = "frontendBackendPool"
  }

  backend_http_settings {
    name                  = "frontendHttpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  request_routing_rule {
    name                       = "httpRule"
    rule_type                  = "Basic"
    priority                   = 9
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "frontendBackendPool"
    backend_http_settings_name = "frontendHttpSettings"
  }

 /* request_routing_rule {
    name                       = "httpsRule"
    rule_type                  = "Basic"
    http_listener_name         = "httpsListener"
    backend_address_pool_name  = "frontendBackendPool"
    backend_http_settings_name = "frontendHttpSettings"
  }
  */

  # Enabling WAF policy
  waf_configuration {
    enabled            = true
    firewall_mode      = "Prevention"
    rule_set_type      = "OWASP"
    rule_set_version   = "3.2"
  }
}
