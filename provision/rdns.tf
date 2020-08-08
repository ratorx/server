resource "hcloud_rdns" "server_ipv4" {
  server_id  = hcloud_server.server.id
  ip_address = hcloud_server.server.ipv4_address
  dns_ptr    = local.fqdn
}

resource "hcloud_rdns" "server_ipv6" {
  server_id  = hcloud_server.server.id
  ip_address = hcloud_server.server.ipv6_address
  dns_ptr    = local.fqdn
}
