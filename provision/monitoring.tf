resource "uptimerobot_alert_contact" "server" {
  friendly_name = "${var.hostname} email"
  type          = "email"
  value         = "server+${var.hostname}@${var.domain}"
}

resource "uptimerobot_monitor" "server" {
  friendly_name = local.fqdn
  type          = "ping"
  interval      = 300
  url           = local.fqdn
}

locals {
  monitors = {
    docker    = 2376
    http      = 80
    https     = 443
    mumble    = 1337
    ssh       = 22
    syncthing = 22000
  }
}

resource "uptimerobot_monitor" "monitors" {
  friendly_name = "${local.fqdn} - ${each.key}"
  type          = "port"
  sub_type      = "custom"
  port          = each.value
  interval      = 300
  url           = local.fqdn

  for_each = local.monitors
}

resource "uptimerobot_status_page" "server" {
  friendly_name = "Status for ${local.fqdn}"
  custom_domain = "status.${local.fqdn}"
  sort          = "a-z"
  monitors      = concat([uptimerobot_monitor.server.id], values(uptimerobot_monitor.monitors)[*].id)
  status        = "active"
}

resource "cloudflare_record" "server_status_cname" {
  zone_id = local.cloudflare_zone_id
  name    = "status.${var.hostname}"
  type    = "CNAME"
  value   = uptimerobot_status_page.server.dns_address
}
