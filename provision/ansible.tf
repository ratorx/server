resource "ansible_host" "app" {
  inventory_hostname = local.fqdn
  groups = ["app"]
  vars = {
    cloudflare_api_token = var.cloudflare_api_token
    backup_passphrase = var.backup_passphrase
  }
}