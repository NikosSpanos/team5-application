# SSH key generated for accessing VM
resource "tls_private_key" "ssh_prod" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# After ssh private key is generated, save it to local file to test connection with the created vm instance
resource "local_file" "private_key" {
  content         = trimspace(tls_private_key.ssh_prod.private_key_pem)
  filename        = "modules/private_connection_key.pem"
  file_permission = "0600"
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm_prod" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.rg.name
  network_interface_ids = [azurerm_network_interface.nic_prod.id] #network id 
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
        key_data = "${chomp(tls_private_key.ssh_prod.public_key_openssh)}"
    }
  }
  tags = var.tags
}