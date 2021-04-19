data "cloudflare_zones" "main" {
  filter {
    name = var.domain
  }
}

data "uptimerobot_alert_contact" "main" {
  friendly_name = var.email
}

locals {
  cloudflare_zone = data.cloudflare_zones.main.zones[0]
}

module "server" {
  source = "./provision/server"

  hostname            = var.hostname
  cloudflare_zone     = local.cloudflare_zone
  ssh_public_key_path = var.ssh_public_key_path
  firewall_ports      = var.ports
}

module "monitoring" {
  source          = "./provision/monitoring"
  alert_contact   = data.uptimerobot_alert_contact.main
  monitored_ports = { for name, port_spec in var.ports : name => port_spec if lookup(port_spec, "monitored", false) }
  server_record   = module.server.a_record
  cloudflare_zone = local.cloudflare_zone
}

module "ansible" {
  source          = "./provision/ansible"
  server_a_record = module.server.a_record
  backup_config = merge(
    var.backup_host_config,
    { passphrase = var.backup_passphrase },
    { private_key_path = var.ssh_private_key_path }
  )
  mail_forwarding_config = merge(
    var.mail_forwarding_host_config,
    { passphrase = var.mail_forwarding_passphrase }
  )
}

resource "cloudflare_record" "aliases" {
  zone_id = local.cloudflare_zone.id
  name    = each.key
  type    = "CNAME"
  value   = module.server.a_record.hostname

  for_each = var.domain_aliases
}

module "compose" {
  source = "./provision/compose"

  server_record        = module.server.a_record
  domain_alias_records = values(cloudflare_record.aliases)
  app_ports            = { for name, port_spec in var.ports : name => port_spec if lookup(port_spec, "app", false) }
  extra_env            = var.compose_env
}
