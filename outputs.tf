output "ssh" {
    value = "ssh ubuntu:SuperSecret1@${data.azurerm_public_ip.public-ip.ip_address}"
}
