terraform {
  backend "remote" {
    organization = "ratorx"
    workspaces {
      name = "server"
    }
  }
}

variable cloudflare_api_token {}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable hetzner_api_token {}
provider "hcloud" {
  token = var.hetzner_api_token
}

variable uptimerobot_api_token {}
provider "uptimerobot" {
  api_key = var.uptimerobot_api_token
}

locals {
  # TODO: When module for_each is stabilized, use fqdns
  fqdn     = split(".", keys(yamldecode(file("inventory.yml"))["all"]["hosts"])[0])
  fqdn_len = length(local.fqdn)

  domain   = join(".", slice(local.fqdn, local.fqdn_len - 2, local.fqdn_len))
  hostname = join(".", slice(local.fqdn, 0, local.fqdn_len - 2))
}

variable ssh_public_key_path {}
module "server" {
  source = "./provision"

  domain              = local.domain
  hostname            = local.hostname
  ssh_public_key_path = var.ssh_public_key_path
}
