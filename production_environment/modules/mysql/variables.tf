variable "location" {
	description = "Resource group location"
}

variable "prefix" {
  description = "Resource group prefix (i.e development/ production)"
}

variable "mysql_master_username" {
	description = "MySql server master username"
	default = "codehubTeam5"
}

variable "mysql_master_password" {
	description = "MySql server master password"
}

variable rg {
	description = "Resource Group Object"
}