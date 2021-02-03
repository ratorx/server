terraform {
  backend "remote" {
    organization = "ratorx"
    workspaces {
      name = "server"
    }
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    uptimerobot = {
      source = "louy/uptimerobot"
    }
  }
  required_version = ">= 0.13"
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
  fqdn     = split(".", keys(yamldecode(file("inventory.yml"))["all"]["children"]["app"]["hosts"])[0])
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
