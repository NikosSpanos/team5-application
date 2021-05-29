variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "production"
}

variable "mysql_master_username" {
	description = "MySql server master username"
	default = "rootteam5"
}

variable "mysql_master_password" {
	description = "MySql server master password"
}

variable rg {
	description = "Resource Group Object"
}