# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet_prod" {
    name                = "${var.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet_prod" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = var.rg.name
    virtual_network_name = azurerm_virtual_network.vnet_prod.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create Public HTTP access
resource "azurerm_public_ip" "public_ip_prod" {
  name                = "${var.prefix}-publicIP"
  resource_group_name = var.rg.name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "nsg_prod" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic_prod" {
    name                      = "${var.prefix}-nic"
    location                  = var.location
    resource_group_name       = var.rg.name

    ip_configuration {
        name                          = "${var.prefix}-nic_conf"
        subnet_id                     = azurerm_subnet.subnet_prod.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip_prod.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_security_prod" {
    network_interface_id      = azurerm_network_interface.nic_prod.id
    network_security_group_id = azurerm_network_security_group.nsg_prod.id
}

# data source
# Use this data source to access information about an existing Public IP Address.
data "azurerm_public_ip" "public_ip_prod" {
  name                = azurerm_public_ip.public_ip_prod.name
  resource_group_name = azurerm_virtual_machine.vm_prod.resource_group_name #Why we configure both Public IP and Azure Network Interface (ANI)
  depends_on          = [azurerm_virtual_machine.vm_prod]
}