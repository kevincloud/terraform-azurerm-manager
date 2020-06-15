data "aws_route53_zone" "primary" {
    zone_id         = var.zone_id
    private_zone = true
}

resource "aws_route53_record" "sentinel-data" { 
    zone_id = data.aws_route53_zone.primary.zone_id
    name = "sentinel-data.${data.aws_route53_zone.primary.name}"
    type = "A"
    ttl = "300"
    records = [data.azurerm_public_ip.public-ip.ip_address]
}
