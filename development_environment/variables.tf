variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "development"
}

variable "tags" {
  type = map

  default = {
    Environment = "Development"
    Version = "1"
    Team = "Team 5"
  }
}

variable "admin_username" {
  default = "codehubTeam5"
}