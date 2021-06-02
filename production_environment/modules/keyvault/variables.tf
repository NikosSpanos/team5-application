variable "location" {
	description = "Resource group location"
}

variable "prefix" {
  description = "Resource group prefix (i.e development/ production)"
}

/*
variable "output_path" {
  description = "The ouput directory to write the private-ssh-key and public-ip-address of vm instance"
}

variable "vm_connection_script_path" {
  description = "The folder directory of vm connection script"
}
*/

variable rg {
	description = "Resource Group Object"
}

variable vm_instance {
	description = "VM instance Object"
}