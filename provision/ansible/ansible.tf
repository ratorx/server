resource "ansible_host" "app" {
  inventory_hostname = var.server_a_record.hostname
  groups             = ["app"]
  vars = {
    backup_passphrase    = var.backup_config.passphrase
    mail_forwarding_json = jsonencode(var.mail_forwarding_config)
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