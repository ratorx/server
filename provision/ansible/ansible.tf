data "cloudflare_api_token_permission_groups" "all" {}
locals {
  cloudflare_permissions = data.cloudflare_api_token_permission_groups.all.permissions
}

resource "cloudflare_api_token" "certbot" {
  name = "certbot on ${var.server_a_record.hostname}"

  policy {
    permission_groups = [
      local.cloudflare_permissions["Zone Read"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  policy {
    permission_groups = [
      local.cloudflare_permissions["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.${var.cloudflare_zone.id}" = "*"
    }
  }

  condition {
    request_ip {
      in = ["${var.server_a_record.value}/32", "${var.server_aaaa_record.value}/128"]
    }
  }
}

resource "ansible_host" "app" {
  inventory_hostname = var.server_a_record.hostname
  groups             = ["app"]
  vars = {
    cloudflare_api_token = cloudflare_api_token.certbot.value
    backup_passphrase    = var.backup_config.passphrase
    ufw_ports_json       = jsonencode(var.used_ports)
  }
}

resource "ansible_host" "backup" {
  inventory_hostname = var.backup_config.fqdn
  groups             = ["backup"]
  vars = {
    ansible_ssh_user             = var.backup_config.username
    ansible_ssh_private_key_file = var.backup_config.private_key_path
  }
}

resource "ansible_group" "all" {
  inventory_group_name = "all"
  children             = ["app", "backup"]
  vars = {
    ansible_connection = "ssh"
    ansible_ssh_user   = "ansible"
  }
}