output "server_name" {
	value = azurerm_mysql_server.mysql_server_dev.name
}

output "administrator_login" {
	value = azurerm_mysql_server.mysql_server_dev.administrator_login
}

output "administrator_password" {
  	value = azurerm_mysql_server.mysql_server_dev.administrator_login_password
}

output "database_name" {
	value = azurerm_mysql_database.mysql_db_dev.name
}

output "fqdn" {
	value = azurerm_mysql_server.mysql_server_dev.fqdn
}