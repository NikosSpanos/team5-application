#-----------------------------------------------------------------
#Return outputs

#MySQL DB
output "output_server_name" {
  value = module.mysql.server_name
}

output "output_mysql_admin_username" {
  value = module.mysql.administrator_login
}

output "output_mysql_admin_password" {
  sensitive = true
  value = module.mysql.administrator_password
}

output "output_mysql_database_name" {
  value = module.mysql.database_name
}

output "output_mysql_fqdn" {
  value = module.mysql.fqdn
}

#Virtual machines
output "output_private_key" {
  sensitive = true
  value = module.virtual_machines.tls_private_key
}

output "output_public_key" {
  sensitive = false
  value = module.virtual_machines.tls_public_key
}

output "output_public_ip" {
  value = module.virtual_machines.public_ip_address
}