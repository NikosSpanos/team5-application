variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "production"
}

variable "tags" {
  type = map

  default = {
    Environment = "Production"
    Version = "1"
    Team = "Team 5"
  }
}

variable "docker_image" {
	description = "Docker image name"
  default = "mysql_image"
}  

variable "docker_image_tag" {
	description = "Docker image tag"
  default = "mysql image for production"
}

variable "mysql_master_password" {
	description = "MySql server master password"
  default = "CodeHubTeam5!@"
}

variable "subscription_id"{
    description = "The subscription id"
    default = "3ec335d6-1a42-463b-95e2-4fde3269c94d"
}

variable "client_appId"{
    default = "5d004607-25e1-490c-82f0-e14c4b688f7c"
}

variable "client_password"{
    default = "WGnNFGParm70lIn5nQr-jbG~E74sCf6QZq"
}

variable "tenant_id"{
    default = "b1732512-60e5-48fb-92e8-8d6902ac1349"
}