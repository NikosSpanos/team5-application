# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

#Random id generator for unique server names
resource "random_string" "string_server" {
	  length  = 8
    lower = true
    upper = false
    special = false
}

#MySQL server
resource "azurerm_mysql_server" "mysql_server_prod" {
  name                         = "${random_string.string_server.result}-team5server"
  location                     = var.location
  resource_group_name          = var.rg.name
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  administrator_login          = var.mysql_master_username
  administrator_login_password = var.mysql_master_password
  version                      = "5.7"
  ssl_enforcement_enabled       = false
  public_network_access_enabled = true
  geo_redundant_backup_enabled  = false
}

# This is the database that the application will use
resource "azurerm_mysql_database" "mysql_db_prod" {
  name                = "${var.prefix}-mysql-db"
  resource_group_name = var.rg.name
  server_name         = azurerm_mysql_server.mysql_server_prod.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# This rule is to enable the 'Allow access to Azure services' checkbox
resource "azurerm_mysql_firewall_rule" "mysql_firewall_prod" {
  name                = "${var.prefix}-mysql-firewall"
  resource_group_name = var.rg.name
  server_name         = azurerm_mysql_server.mysql_server_prod.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}