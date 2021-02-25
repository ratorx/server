resource "uptimerobot_monitor" "ping" {
  friendly_name = var.server_record.hostname
  type          = "ping"
  interval      = 300
  url           = var.server_record.hostname
  alert_contact {
    id = var.alert_contact.id
  }
}

resource "uptimerobot_monitor" "monitors" {
  friendly_name = "${var.server_record.hostname} - ${each.key}"
  type          = "port"
  sub_type      = "custom"
  port          = each.value
  interval      = 300
  url           = var.server_record.hostname
  alert_contact {
    id = var.alert_contact.id
  }

  for_each = { for port_name, port in var.monitored_ports : port_name => port.port }
}

resource "uptimerobot_status_page" "main" {
  friendly_name = "Status for ${var.server_record.hostname}"
  custom_domain = "status.${var.server_record.hostname}"
  sort          = "a-z"
  monitors      = concat([uptimerobot_monitor.ping.id], values(uptimerobot_monitor.monitors)[*].id)
  status        = "active"
}

resource "cloudflare_record" "status_cname" {
  zone_id = var.cloudflare_zone.id
  name    = "status.${var.server_record.name}"
  type    = "CNAME"
  value   = uptimerobot_status_page.main.dns_address
}