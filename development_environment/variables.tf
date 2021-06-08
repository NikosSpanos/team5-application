variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
	type = string
	description = "Accepted values are development/production (those differentiate the pipeline infrastructure)"
}

variable "tags" {
  type = map
  default = {
    Environment = "Infrastructure Pipeline"
    Version = "1"
    Team = "Team 5"
  }
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

variable "admin_username" {
  description = "username for vm instance"
  default = "codehubTeam5"
}

variable "subscription_id"{
  type        = string
  sensitive   = true
}

variable "client_appId"{
  type        = string
  sensitive   = true
}

variable "client_password"{
  type        = string
  sensitive   = true
}

variable "tenant_id"{
  type        = string
  sensitive   = true
}