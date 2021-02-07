# base server records
resource "cloudflare_record" "a" {
  zone_id = var.cloudflare_zone.id
  name    = var.hostname
  type    = "A"
  value   = hcloud_server.main.ipv4_address
}

resource "cloudflare_record" "aaaa" {
  zone_id = var.cloudflare_zone.id
  name    = var.hostname
  type    = "AAAA"
  value   = hcloud_server.main.ipv6_address
}

locals {
  domain_aliases = ["mumble", "gh"]
}

resource "cloudflare_record" "aliases" {
  zone_id = var.cloudflare_zone.id
  name = each.key
  type = "CNAME"
  value = local.fqdn

  for_each = toset(local.domain_aliases)
}

# application-specific
locals {
  mumble_srv_names = [cloudflare_record.aliases["mumble"].name, var.hostname]
}

resource "cloudflare_record" "mumble_srv" {
  zone_id = var.cloudflare_zone.id
  name    = "_mumble._tcp.${each.key}"
  type    = "SRV"

  data = {
    service  = "_mumble"
    proto    = "_tcp"
    name     = each.key
    priority = 0
    weight   = 1
    port     = 1337
    target   = local.fqdn
  }

  for_each = toset(local.mumble_srv_names)
}