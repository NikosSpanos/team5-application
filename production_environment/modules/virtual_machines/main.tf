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
  allocation_method   = "Static"
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "nsg_prod" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg.name
}

resource "azurerm_network_security_rule" "ssh_rule_prod" {
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
  network_security_group_name = azurerm_network_security_group.nsg_prod.name
}

resource "azurerm_network_security_rule" "http_rule_prod" {
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
  network_security_group_name = azurerm_network_security_group.nsg_prod.name
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

# SSH key generated for accessing VM
resource "tls_private_key" "ssh_prod" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm_prod" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.rg.name
  network_interface_ids = [azurerm_network_interface.nic_prod.id]
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
        key_data = "${chomp(tls_private_key.ssh_prod.public_key_openssh)}" #this openssh connection key will help to connect with Ansible
    }
  }

  connection {
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = "${chomp(tls_private_key.ssh_prod.private_key_pem)}"
      host        = "${azurerm_public_ip.public_ip_prod.ip_address}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y openjdk-8-jdk",
      "sudo apt install -y python2.7 python-pip",
      "pip install setuptools"
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

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     bash ${var.cicd_pipeline_repo_path}/vm_connection.sh
  #     sudo mkdir -p /tmp/resources
  #     echo '${chomp(tls_private_key.ssh_prod.private_key_pem)}' > /tmp/resources/${var.prefix}-private-key-connector
  #     sudo mv /tmp/resources/${var.prefix}-private-key-connector /home/${var.admin_username}/${var.prefix}-private-key-connector
  #     echo '${azurerm_public_ip.public_ip_prod.ip_address} ansible_user=${var.admin_username} ansible_ssh_private_key=/home/${var.admin_username}/${var.prefix}-private-key-connector' | sudo tee -a /etc/ansible/hosts
  #   EOT
  # }
}

# data source
# Use this data source to access information about an existing Public IP Address.
data "azurerm_public_ip" "public_ip_prod" {
  name                = azurerm_public_ip.public_ip_prod.name
  resource_group_name = azurerm_virtual_machine.vm_prod.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm_prod]
}