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
  features {

  }
  subscription_id = var.subscription_id
  client_id       = var.client_appId
  client_secret   = var.client_password
  tenant_id       = var.tenant_id
}

# Create a resource group for development environment
resource "azurerm_resource_group" "rg_prod" {
  name     = "${var.prefix}-resource-group"
  location = var.location
  tags     = var.tags
}

# Declare curent config
data "azurerm_client_config" "current" {}

#Random id generator for unique server names
resource "random_string" "string_keyvault" {
	  length  = 5
    lower = true
    upper = false
    special = false
    number = false
}

# Create keyvault
resource "azurerm_key_vault" "keyvault_repo" {
  depends_on                      = [ azurerm_resource_group.rg_prod ]
  name                            = "${random_string.string_keyvault.result}-team5keyvault"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg_prod.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled        = false
  soft_delete_retention_days      = 8

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "Get",
      "List",
      "purge",
      "recover",
      "restore",
      "set",
    ]

    storage_permissions = [
      "get",
    ]
  }

  contact {
    email = "spanos.nikolaos@outlook.com"
    name = "Nikos Spanos"
  }
}

resource "azurerm_key_vault_key" "ssh_generated" {
  name         = "generated-certificate"
  key_vault_id = azurerm_key_vault.keyvault_repo.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Save the ssh_key secret to the established keyvault
resource "azurerm_key_vault_secret" "ssh_key_secret" {
  name         = "${var.prefix}-secret"
  value        = trimspace(module.virtual_machines.tls_private_key)
  key_vault_id = azurerm_key_vault.keyvault_repo.id
}

resource "null_resource" "test" {
  # Set the executable permission for scripts
  provisioner "local-exec" {
    command = "echo '${azurerm_key_vault_secret.ssh_key_secret.value}' > /home/nikosspanos/Documents/team5/production_environment/private-key-connector"
  }
  provisioner "local-exec" {
    command = "chmod 600 /home/nikosspanos/Documents/team5/production_environment/private-key-connector"
  }
  provisioner "local-exec" {
    command = "echo ${module.virtual_machines.public_ip_address} > /home/nikosspanos/Documents/team5/production_environment/public-ip-value"
  }
}

# https://github.com/marlinspike/terraform-azure-vms/blob/master/variables.tf
module "virtual_machines" {
    source = "./modules/virtual_machines"
    location = var.location
    prefix = var.prefix
    rg = azurerm_resource_group.rg_prod
    admin_username = var.admin_username
}

module "mysql" {
    source = "./modules/mysql"
    rg = azurerm_resource_group.rg_prod
    location = var.location
    prefix = var.prefix
    mysql_master_username = var.mysql_master_username
    mysql_master_password = var.mysql_master_password
}