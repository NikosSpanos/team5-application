variable "location" {
	description = "Resource group location"
}

variable "prefix" {
  description = "Resource group prefix (i.e development/ production)"
}

variable "admin_username" {
  description = "username for vm instance"
  default = "codehubTeam5"
}

variable rg {
	description = "Resource Group Object"
}

variable "public_ip_cicd_vm" {
  description = "Public IP address of CICD pipeline vm instance"
  type        = string
  sensitive   = true
}

variable "cicd_pipeline_repo_path" {
  description = "Local repository path of the cicd pipeline"
  type        = string
  sensitive   = true
}