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
