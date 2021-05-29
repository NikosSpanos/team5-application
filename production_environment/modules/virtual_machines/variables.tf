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

variable "admin_username" {
  default = "codehubTeam5"
}

variable rg {
	description = "Resource Group Object"
}