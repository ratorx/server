locals {
  cloudflare_zone_id = data.cloudflare_zones.base.zones[0].id
}

data "cloudflare_zones" "base" {
  filter {
    name = var.domain
  }
}

# base server records
resource "cloudflare_record" "server_a" {
  zone_id = local.cloudflare_zone_id
  name    = var.hostname
  type    = "A"
  value   = hcloud_server.server.ipv4_address
}

resource "cloudflare_record" "server_aaaa" {
  zone_id = local.cloudflare_zone_id
  name    = var.hostname
  type    = "AAAA"
  value   = hcloud_server.server.ipv6_address
}

# application-specific
resource "cloudflare_record" "mumble_srv" {
  zone_id = local.cloudflare_zone_id
  name    = "_mumble._tcp.${var.hostname}"
  type    = "SRV"

  data = {
    service  = "_mumble"
    proto    = "_tcp"
    name     = var.hostname
    priority = 0
    weight   = 1
    port     = 1337
    target   = local.fqdn
  }
}
