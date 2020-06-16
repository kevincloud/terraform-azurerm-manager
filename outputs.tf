output "A-ssh" {
    value = "ssh ubuntu@${data.azurerm_public_ip.public-ip.ip_address}"
}

output "B-api" {
    value = "http://sentinel-data.${var.dns_zone}:8080/"
}

output "C-web" {
    value = "http://sentinel-data.${var.dns_zone}/"
}
