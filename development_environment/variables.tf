variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
	type = string
	description = "Accepted values are development/production (those differentiate the pipeline infrastructure)"
}

/*
variable "output_path" {
	type = string
  description = "The ouput directory to write the private-ssh-key and public-ip-address of vm instance"
}

variable "vm_connection_script_path" {
	type = string
  description = "The folder directory of vm connection script"
}
*/

variable "tags" {
  type = map
  default = {
    Environment = "Infrastructure Pipeline"
    Version = "1"
    Team = "Team 5"
  }
}

variable "mysql_master_username" {
	description = "MySql server master username"
	default = "codehubTeam5"
}

variable "mysql_master_password" {
	description = "MySql server master password"
  default = "H@Sh1CoR3!"
}

variable "admin_username" {
  description = "username for vm instance"
  default = "codehubTeam5"
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