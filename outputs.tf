output "A-ssh" {
    value = "ssh ${var.linux_user}@${data.azurerm_public_ip.public-ip.ip_address}"
}

output "B-api" {
    value = "http://sentinel-data.${var.dns_zone}:8080/"
}

output "C-web" {
    value = "http://sentinel-data.${var.dns_zone}/"
}

# output "D-acctkey" {
#     value = azurerm_cosmosdb_account.cosmosdb.primary_master_key
# }
