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
  subscription_id = var.subscription_id
  client_id       = var.client_appId
  client_secret   = var.client_password
  tenant_id       = var.tenant_id
}

# Create a resource group for development environment
resource "azurerm_resource_group" "rg_prod" {
  name     = "${var.prefix}-resource_group"
  location = var.location
  tags     = var.tags
}

# https://github.com/marlinspike/terraform-azure-vms/blob/master/variables.tf
module "virtual_machines" {
    source = "./modules/virtual_machines"
    location = var.location
    rg = azurerm_resource_group.rg_prod
}

module "java_application" {
    source = "./modules/java_app"
    rg = azurerm_resource_group.rg_prod
    location = var.location
    mysql = module.mysql
    docker_image = var.docker_image
    docker_image_tag = var.docker_image_tag
    mysql_master_password = var.mysql_master_password
}

module "mysql" {
    source = "./modules/mysql"
    rg = azurerm_resource_group.rg_prod
    mysql_master_password = var.mysql_master_password
}

output "output_private_key" {
  sensitive = true
  value = module.virtual_machines.tls_private_key
}

output "output_public_ip" {
  value = module.virtual_machines.public_ip_address
}