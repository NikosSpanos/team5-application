output "name" {
	value = azurerm_app_service.app_service_prod.name
}

output "default_site_hostname" {
	value = azurerm_app_service.app_service_prod.default_site_hostname
}