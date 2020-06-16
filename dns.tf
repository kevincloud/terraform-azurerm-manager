# data "aws_route53_zone" "primary" {
#     zone_id         = var.zone_id
#     private_zone = true
# }

# resource "aws_route53_record" "sentinel-data" { 
#     zone_id = data.aws_route53_zone.primary.zone_id
#     name = "sentinel-data.${data.aws_route53_zone.primary.name}"
#     type = "A"
#     ttl = "300"
#     records = [data.azurerm_public_ip.public-ip.ip_address]
# }

data "azurerm_resource_group" "static-rg" {
    name = "kevinc-static-resources"
}

resource "azurerm_dns_a_record" "sentinel-data" {
  name                = "sentinel-data"
  zone_name           = "kcochran.azure.hashidemos.io"
  resource_group_name = data.azurerm_resource_group.static-rg.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.public-ip.ip_address]
}
