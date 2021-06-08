variable "location" {
	description = "Resource group location"
}

variable "prefix" {
  description = "Resource group prefix (i.e development/ production)"
}

variable rg {
	description = "Resource Group Object"
}

variable vm_instance {
	description = "Development environment vm instance object"
}

variable "mysql_master_username" {
  description = "Server administrator username"
  type        = string
  sensitive   = true
}

variable "mysql_master_password" {
  description = "Server administrator password"
  type        = string
  sensitive   = true
}

variable "public_ip_cicd_vm" {
  description = "Public IP address of CICD pipeline vm instance"
  type        = string
  sensitive   = true
}