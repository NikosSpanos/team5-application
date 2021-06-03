# Declare curent config
data "azurerm_client_config" "current" {}

#Random id generator for unique server names
resource "random_string" "string_keyvault" {
	length  = 5
    lower = true
    upper = false
    special = false
    number = false
}

# Create keyvault
resource "azurerm_key_vault" "keyvault_repo_prod" {
  depends_on                      = [ var.rg ]
  name                            = "${random_string.string_keyvault.result}-team5keyvault"
  location                        = var.location
  resource_group_name             = var.rg.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled        = false
  soft_delete_retention_days      = 8

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]

    storage_permissions = [
      "get",
    ]
  }

  contact {
    email = "nspanos@athtech.gr"
    name = "Nikos Spanos"
  }
}

/*
resource "azurerm_key_vault_key" "ssh_generated" {
  name         = "${var.prefix}-generated-certificate"
  key_vault_id = azurerm_key_vault.keyvault_repo.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
*/

# Save the ssh_key secret to the established keyvault
resource "azurerm_key_vault_secret" "ssh_key_secret" {
  name         = "${var.prefix}-secret"
  value        = trimspace(var.vm_instance.tls_private_key)
  key_vault_id = azurerm_key_vault.keyvault_repo_prod.id
}

/*
resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "\nif [ -d ${var.output_path} ]; then\necho '${var.output_path} directory found' exit 1\n else mkdir ${var.output_path}\n fi"
  }
  provisioner "local-exec" {
    command = "echo '${azurerm_key_vault_secret.ssh_key_secret.value}' > ${var.output_path}/${var.prefix}-private-key-connector"
  }
    provisioner "local-exec" {
    command = "echo ${var.vm_instance.public_ip_address} > ${var.output_path}/${var.prefix}-public-ip-value"
  }
  provisioner "local-exec" {
    command = "chmod 600 ${var.output_path}/${var.prefix}-private-key-connector ${var.vm_connection_script_path}/${var.prefix}_environment/vm_connection.sh"
  }
}
*/