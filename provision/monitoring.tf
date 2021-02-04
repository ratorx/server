data "uptimerobot_alert_contact" "email" {
  friendly_name = local.fqdn
}

resource "uptimerobot_monitor" "ping" {
  friendly_name = local.fqdn
  type          = "ping"
  interval      = 300
  url           = local.fqdn
  alert_contact {
    id = data.uptimerobot_alert_contact.email.id
  }
}

locals {
  monitors = {
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
  alert_contact {
    id = data.uptimerobot_alert_contact.email.id
  }

  for_each = local.monitors
}

resource "uptimerobot_status_page" "main" {
  friendly_name = "Status for ${local.fqdn}"
  custom_domain = "status.${local.fqdn}"
  sort          = "a-z"
  monitors      = concat([uptimerobot_monitor.ping.id], values(uptimerobot_monitor.monitors)[*].id)
  status        = "active"
}

resource "cloudflare_record" "status_cname" {
  zone_id = local.cloudflare_zone_id
  name    = "status.${var.hostname}"
  type    = "CNAME"
  value   = uptimerobot_status_page.main.dns_address
}
