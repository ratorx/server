variable "hostname" {
  type = string
  description = "Hostname of the server to provision"
}

variable "ssh_public_key_path" {
  type = string
  description = "Path to the temporary public key used to bootstrap the server"
}

variable "cloudflare_zone" {
  type = object({
    id = string
    name = string
  })
  description = "Base Cloudflare zone to create DNS records in"
}

variable "backup_passphrase" {
  type = string
  description = "Passphrase to the Borg backup repository"
  sensitive = true
}

locals {
  fqdn = cloudflare_record.a.hostname
}

output "fqdn" {
  description = "FQDN of the server"
  value = local.fqdn
}
