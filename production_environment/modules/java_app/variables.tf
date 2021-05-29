variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "production"
}

variable rg {
	description = "Resource Group Object"
}

variable mysql {
	description = "MySQL Object"
}

variable "docker_image" {
	description = "Docker image name"
}  

variable "docker_image_tag" {
	description = "Docker image tag"
}

variable "mysql_master_password" {
	description = "Custom mysql password to connect to database server"
}