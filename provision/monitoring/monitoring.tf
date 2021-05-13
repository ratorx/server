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
  sort          = "a-z"
  monitors      = concat([uptimerobot_monitor.ping.id], values(uptimerobot_monitor.monitors)[*].id)
  status        = "active"
}

// Keep a pointer to the actual status page in DNS in case the server goes down.
resource "cloudflare_record" "status_txt" {
  zone_id = var.cloudflare_zone.id
  name    = "_status.${var.server_record.name}"
  type    = "TXT"
  value   = uptimerobot_status_page.main.standard_url
}