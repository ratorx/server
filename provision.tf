terraform {
  backend "remote" {
    organization = "ratorx"
    workspaces {
      name = "server"
    }
  }
  required_providers {
    ansible = {
      source = "nbering/ansible"
    }
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

variable "ssh_public_key_path" {}
variable "app_host" {
  type = object({
    name = string
    backup_passphrase = string
  })
}

variable "ports" {
  type = map(object({
    port = number
    protocol = string
    monitored = bool
  }))
}

module "server" {
  source = "./provision"

  cloudflare_zone     = data.cloudflare_zones.base.zones[0]
  hostname            = var.app_host.name
  ssh_public_key_path = var.ssh_public_key_path
  ports = var.ports

  backup_passphrase = var.app_host.backup_passphrase
}

variable "backup_host" {
  type = object({
    fqdn = string
    username = string
    private_key_path = string
  })
}

resource "ansible_host" "backup" {
  inventory_hostname = var.backup_host.fqdn
  groups = ["backup"]
  vars = {
    ansible_ssh_user = var.backup_host.username
    ansible_ssh_private_key_file = var.backup_host.private_key_path
  }
}

resource "ansible_group" "all" {
  inventory_group_name = "all"
  children = ["app", "backup"]
  vars = {
    ansible_connection = "ssh"
    ansible_ssh_user = "ansible"
  }
}