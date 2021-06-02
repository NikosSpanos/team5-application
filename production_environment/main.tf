# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  backend "remote" {
    organization = "codehub-spanos"

    workspaces {
      name = "team5-prod"
    }
  }
}

provider "azurerm" {
  features {}
  # This is used for creating a service principal connection with Azure. To connect with azure CLI simply comment out the following four lines
  #Owner
  subscription_id = var.subscription_id
  client_id       = var.client_appId
  client_secret   = var.client_password
  tenant_id       = var.tenant_id
}

/*
resource "tfe_organization" "prod_config" {
  name  = "codehub-spanos"
  email = "nikspanos@athtech.gr"
}

resource "tfe_workspace" "prod_workspace" {
  name         = "team5-prod"
  organization = tfe_organization.prod_config.id
}
*/

/*
resource "tfe_variable" "prod_prefix" {
  key          = "prefix"
  value        = "production"
  category     = "terraform"
  workspace_id = tfe_workspace.prod_workspace.id
  description  = "string text var to distinguish infrastructure from development to production resours"
}

resource "tfe_variable" "prod_output_path" {
  key          = "output_path"
  value        = "/tmp/team5-resources"
  category     = "terraform"
  workspace_id = tfe_workspace.prod_workspace.id
  description  = "the path to write ssh private key and public ip address to local machine where the terraform apply is executed"
}

resource "tfe_variable" "prod_vm_connection_script_path" {
  key          = "vm_connection_script_path"
  value        = "/home/nspanos/Documents/team5"
  category     = "terraform"
  workspace_id = tfe_workspace.prod_workspace.id
  description  = "the path folder where the vm_connection.sh script exists. This script is downloaded along with cloned git repository"
}
*/

# Create a resource group for development environment
resource "azurerm_resource_group" "rg_prod" {
  name     = "${var.prefix}-resource-group"
  location = var.location
  tags     = var.tags
}

# https://github.com/marlinspike/terraform-azure-vms/blob/master/variables.tf
module "keyvault" {
    source = "./modules/keyvault"
    location = var.location
    prefix = var.prefix
    #output_path = var.output_path
    #vm_connection_script_path = var.vm_connection_script_path
    vm_instance = module.virtual_machines
    rg = azurerm_resource_group.rg_prod
}

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