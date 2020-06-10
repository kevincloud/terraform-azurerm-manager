# data "azurerm_client_config" "current" {}

# resource "azurerm_key_vault" "key-vault" {
#     name                        = "${var.identifier}mainvault"
#     location                    = azurerm_resource_group.res-group.location
#     resource_group_name         = azurerm_resource_group.res-group.name
#     enabled_for_disk_encryption = true
#     tenant_id                   = data.azurerm_client_config.current.tenant_id
#     soft_delete_enabled         = true
#     purge_protection_enabled    = false

#     sku_name = "standard"

#     access_policy {
#         tenant_id = data.azurerm_client_config.current.tenant_id
#         object_id = data.azurerm_client_config.current.object_id

#         key_permissions = [
#             "create",
#             "get",
#         ]

#         secret_permissions = [
#             "list",
#             "set",
#             "get",
#             "delete"
#         ]

#         storage_permissions = [
#             "get",
#         ]
#     }
# }

# resource "azurerm_key_vault_secret" "accountkey" {
#     name         = "AccountKey"
#     value        = var.account_key
#     key_vault_id = azurerm_key_vault.key-vault.id
# }

# resource "azurerm_key_vault_secret" "idkey" {
#     name         = "Identifier"
#     value        = var.identifier
#     key_vault_id = azurerm_key_vault.key-vault.id
# }
