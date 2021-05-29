# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

#MySQL server
resource "azurerm_mysql_server" "mysql_server_prod" {
  name                = "${var.prefix}-mysql-server1"
  location            = var.location
  resource_group_name = var.rg.name
  sku_name     = "B_Gen5_2"
  
  #storage profile has been deprecated, included values need to be moved on the upper level
  storage_profile {
	  storage_mb = 5120
      backup_retention_days = 7
	  geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.mysql_master_username
  administrator_login_password = var.mysql_master_password
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}

# This is the database that the application will use
resource "azurerm_mysql_database" "mysql_db_prod" {
  name                = "${var.prefix}_mysql_db"
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
