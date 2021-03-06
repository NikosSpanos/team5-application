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
resource "azurerm_virtual_network" "vnet_dev" {
    name                = "${var.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet_dev" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = var.rg.name
    virtual_network_name = azurerm_virtual_network.vnet_dev.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create Public HTTP access
resource "azurerm_public_ip" "public_ip_dev" {
  name                = "${var.prefix}-publicIP"
  resource_group_name = var.rg.name
  location            = var.location
  allocation_method   = "Static"
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "nsg_dev" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg.name
}

resource "azurerm_network_security_rule" "ssh_rule_dev" {
  name                        = "SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_dev.name
}

resource "azurerm_network_security_rule" "http_rule_dev" {
  name                        = "http_connection"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_dev.name
}

# Create network interface
resource "azurerm_network_interface" "nic_dev" {
    name                      = "${var.prefix}-nic"
    location                  = var.location
    resource_group_name       = var.rg.name

    ip_configuration {
        name                          = "${var.prefix}-nic_conf"
        subnet_id                     = azurerm_subnet.subnet_dev.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip_dev.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_security_dev" {
    network_interface_id      = azurerm_network_interface.nic_dev.id
    network_security_group_id = azurerm_network_security_group.nsg_dev.id
}

# SSH key generated for accessing VM
resource "tls_private_key" "ssh_dev" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm_dev" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.rg.name
  network_interface_ids = [azurerm_network_interface.nic_dev.id]
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
        key_data = "${chomp(tls_private_key.ssh_dev.public_key_openssh)}"
    }
  }

  connection {
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = "${chomp(tls_private_key.ssh_dev.private_key_pem)}"
      host        = "${azurerm_public_ip.public_ip_dev.ip_address}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y openjdk-8-jdk"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]
  }
}

# data source
# Use this data source to access information about an existing Public IP Address.
data "azurerm_public_ip" "public_ip_dev" {
  name                = azurerm_public_ip.public_ip_dev.name
  resource_group_name = azurerm_virtual_machine.vm_dev.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm_dev]
}