# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

resource "azurerm_app_service_plan" "service_plan_prod" {
  name                = "${var.prefix}-ASP"
  location            = var.location
  resource_group_name = var.rg.name
  kind = "Linux"
  reserved = "true"

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app_service_prod" {
  name                = "${var.prefix}-AS"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = azurerm_app_service_plan.service_plan_prod.id

 site_config {
	app_command_line = ""
	linux_fx_version = "DOCKER|${var.docker_image}:${var.docker_image_tag}"
	use_32_bit_worker_process = "true"
 }
 
 app_settings = {
	"WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
	"DOCKER_REGISTRY_SERVER_URL" = "https://index.docker.io"
	
	"SPRING_DATASOURCE_URL"      = "jdbc:mysql://${var.mysql.fqdn}:3306/${var.mysql.database_name}?useUnicode=true&characterEncoding=utf8&useSSL=false&useLegacyDatetimeCode=false&serverTimezone=UTC"
    "SPRING_DATASOURCE_USERNAME" = "${var.mysql.administrator_login}@${var.mysql.name}"
    "SPRING_DATASOURCE_PASSWORD" = var.mysql_master_password
 }  
}