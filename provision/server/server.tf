resource "hcloud_ssh_key" "temp" {
  name       = "temp"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_server" "main" {
  name        = var.hostname
  server_type = "cpx11"
  image       = "debian-10"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.temp.id]
  firewall_ids = [hcloud_firewall.main_firewall.id]
}

resource "hcloud_rdns" "ipv4" {
  server_id  = hcloud_server.main.id
  ip_address = hcloud_server.main.ipv4_address
  dns_ptr    = local.fqdn
}

resource "hcloud_rdns" "ipv6" {
  server_id  = hcloud_server.main.id
  ip_address = hcloud_server.main.ipv6_address
  dns_ptr    = cloudflare_record.aaaa.hostname
}

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

resource "cloudflare_record" "mail_forwarding_spf" {
  zone_id = var.cloudflare_zone.id
  name    = var.hostname
  type    = "TXT"
  // Assumes that email is configured on the base domain
  // Uses the base domain's SPF
  value = "v=spf1 include:${var.cloudflare_zone.name} ?all"
}