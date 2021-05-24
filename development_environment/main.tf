# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for development environment
resource "azurerm_resource_group" "mainDev" {
  name     = "${var.prefix}-resource_group"
  location = var.location
  tags     = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "mainDev" {
    name                = "${var.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.mainDev.name
}

# Create subnet
resource "azurerm_subnet" "mainDev" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = azurerm_resource_group.mainDev.name
    virtual_network_name = azurerm_virtual_network.mainDev.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create Public HTTP access
resource "azurerm_public_ip" "mainDev" {
  name                = "${var.prefix}-acceptancePublicIp"
  resource_group_name = azurerm_resource_group.mainDev.name
  location            = azurerm_resource_group.mainDev.location
  allocation_method   = "Static"

  tags = var.tags
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "mainDev" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.mainDev.location
  resource_group_name = azurerm_resource_group.mainDev.name

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
resource "azurerm_network_interface" "mainDev" {
    name                      = "${var.prefix}-nic"
    location                  = azurerm_resource_group.mainDev.location
    resource_group_name       = azurerm_resource_group.mainDev.name

    ip_configuration {
        name                          = "${var.prefix}-NicConfiguration"
        subnet_id                     = azurerm_subnet.mainDev.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.mainDev.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "mainDev" {
    network_interface_id      = azurerm_network_interface.mainDev.id
    network_security_group_id = azurerm_network_security_group.mainDev.id
}

# SSH key generated for accessing VM
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" {
    sensitive = false
    value = tls_private_key.example_ssh.public_key_pem
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "mainDev_1" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.mainDev.location
  resource_group_name   = azurerm_resource_group.mainDev.name
  network_interface_ids = [azurerm_network_interface.mainDev.id] #network id 
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-mycomputer"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = "${chomp(tls_private_key.example_ssh.public_key_openssh)}"
    }
  }
  
  tags = var.tags
}

# data source
# Use this data source to access information about an existing Public IP Address.
data "azurerm_public_ip" "mainDev" {
  name                = azurerm_public_ip.mainDev.name
  resource_group_name = azurerm_virtual_machine.mainDev_1.resource_group_name #Why we configure both Public IP and Azure Network Interface (ANI)
  depends_on          = [azurerm_virtual_machine.mainDev_1]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.mainDev.ip_address
}