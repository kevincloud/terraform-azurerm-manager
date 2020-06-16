data "azurerm_resource_group" "static-rg" {
    name = "kevinc-static-resources"
}

resource "azurerm_dns_a_record" "sentinel-data" {
  name                = "sentinel-data"
  zone_name           = var.dns_zone
  resource_group_name = data.azurerm_resource_group.static-rg.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.public-ip.ip_address]
}
