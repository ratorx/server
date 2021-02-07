data "cloudflare_api_token_permission_groups" all {}
locals {
  cloudflare_permissions = data.cloudflare_api_token_permission_groups.all.permissions
}

resource "cloudflare_api_token" "certbot" {
  name = "certbot on ${local.fqdn}"

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
      in = ["${hcloud_server.main.ipv4_address}/32", "${hcloud_server.main.ipv6_address}/128"]
    }
  }
}

resource "ansible_host" "app" {
  inventory_hostname = local.fqdn
  groups = ["app"]
  vars = {
    cloudflare_api_token = cloudflare_api_token.certbot.value
    backup_passphrase = var.backup_passphrase
  }
}