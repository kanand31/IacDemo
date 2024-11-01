variable "cidr_block" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "vnet_location" {
    default = "East US"
}
variable "subnets" {
  description = "Map of subnet names to address prefixes"
  type = map(object({
    address_prefix = string
  }))
  default = {
    frontend = { address_prefix = "10.0.1.0/24" }
    backend  = { address_prefix = "10.0.2.0/24" }
    db       = { address_prefix = "10.0.3.0/24" }
    appgw    = { address_prefix = "10.0.4.0/24" }
  }
}

variable "network_security_groups" {
  description = "Map of NSG names to their security rules"
  type = map(object({

    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  default = {
    frontend = {
     
      security_rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "10.0.4.0/24" # App Gateway subnet
          destination_address_prefix = "10.0.1.0/24"  # Frontend subnet
        },
        {
          name                       = "AllowHTTPS"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.0.4.0/24" # App Gateway subnet
          destination_address_prefix = "10.0.1.0/24"  # Frontend subnet
        },
      ]
    },
    backend = {
      
      security_rules = [
        {
          name                       = "AllowAppTraffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24"  # Frontend subnet
          destination_address_prefix = "10.0.2.0/24"  # Backend subnet
        },
      ]
    },
    db = {

      security_rules = [
        {
          name                       = "AllowDbAccess"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3306"
          source_address_prefix      = "10.0.2.0/24"  # Backend subnet
          destination_address_prefix = "10.0.3.0/24"  # DB subnet
        },
      ]
    },
    appgw = {
        security_rules = [
 {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix  = "*"
  },
 {
    name                       = "Allow_HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix  = "*"
  },
   {
    name                       = "Allow_appgwdefaults"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix  = "*"
  },
        ]
    }
}
}