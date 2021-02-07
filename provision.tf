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

variable "cloudflare_api_token" {}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "hetzner_api_token" {}
provider "hcloud" {
  token = var.hetzner_api_token
}

variable "uptimerobot_api_token" {}
provider "uptimerobot" {
  api_key = var.uptimerobot_api_token
}

variable "domain" {
  type = string
  description = "Base domain for DNS entries"
}

data "cloudflare_zones" "base" {
  filter {
    name = var.domain
  }
}

locals {
  fqdns = [for item in keys(yamldecode(file("inventory.yml"))["all"]["children"]["app"]["hosts"]) : split(".", item)]
  hosts = { for fqdn in local.fqdns : join(".", fqdn) => {
    hostname = join(".", slice(fqdn, 0, length(fqdn) - 2))
  } }
}

variable "ssh_public_key_path" {}
module "server" {
  source = "./provision"

  cloudflare_zone     = data.cloudflare_zones.base.zones[0]
  hostname            = each.value.hostname
  ssh_public_key_path = var.ssh_public_key_path

  for_each = local.hosts
}
