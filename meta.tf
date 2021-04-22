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
  type        = string
  description = "Main domain for DNS entries"
}

variable "hostname" {
  type        = string
  description = "Short hostname of the app server"
}

variable "email" {
  type        = string
  description = "Uptimerobot contact name (needs external setup)"
}

variable "backup_host_config" {
  type = object({
    fqdn       = string
    username   = string
    public_key = string
  })
  description = "Details for the backup server"
}

variable "backup_passphrase" {
  type        = string
  description = "Passphrase to the application backup on the backup server"
  sensitive   = true
}

variable "mail_forwarding_host_config" {
  type = object({
    fqdn     = string
    username = string
  })
  description = "Details for the mail forwarding server"
}

variable "mail_forwarding_passphrase" {
  type        = string
  description = "Passphrase to the mail forwarding server for system notifications"
  sensitive   = true
}

variable "compose_env" {
  type        = map(string)
  description = "Extra environment variables to pass to docker compose"
  sensitive   = true
}

# Variables configured in this file
variable "ssh_private_key_path" {
  default = "./misc/ssh/id_ed25519"
}

variable "ssh_public_key_path" {
  default = "./misc/ssh/id_ed25519.pub"
}

variable "ports" {
  default = {
    ssh = {
      port      = 22
      protocol  = "tcp"
      monitored = true
    }
    syncthing = {
      port      = 22000
      protocol  = "tcp"
      monitored = true
      app       = true
    }
    syncthing_discovery = {
      port     = 21027
      protocol = "udp"
      app      = true
    }
    http = {
      port      = 80
      protocol  = "tcp"
      monitored = true
      app       = true
    }
    https = {
      port      = 443
      protocol  = "tcp"
      monitored = true
      app       = true
    }
  }
}

variable "domain_aliases" {
  type    = set(string)
  default = ["gh"]
}

# TODO: Pass in status CNAME to domain aliases
# TODO: Make applications depend on their domain alias (even if they don't use it)
# TODO: Configure caddy to use status CNAME environment variable for redirects