output "server_name" {
	value = azurerm_mysql_server.mysql_server_prod.name
}

output "administrator_login" {
	value = azurerm_mysql_server.mysql_server_prod.administrator_login
}

output "administrator_password" {
  	value = azurerm_mysql_server.mysql_server_prod.administrator_login_password
}

output "database_name" {
	value = azurerm_mysql_database.mysql_db_prod.name
}

output "fqdn" {
	value = azurerm_mysql_server.mysql_server_prod.fqdn
}