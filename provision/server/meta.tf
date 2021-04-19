terraform {
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

variable "hostname" {
  type        = string
  description = "Hostname of the app server"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the temporary public key used to bootstrap the server"
}

variable "cloudflare_zone" {
  type = object({
    id   = string
    name = string
  })
  description = "Base Cloudflare zone to create DNS records in"
}

variable "firewall_ports" {
  type = map(object({
    port     = number
    protocol = string
  }))
}

locals {
  fqdn = cloudflare_record.a.hostname
}

output "fqdn" {
  description = "FQDN of the server"
  value       = local.fqdn
}

output "a_record" {
  description = "A record of the server"
  value       = cloudflare_record.a
}

output "aaaa_record" {
  description = "AAAA record of the server"
  value       = cloudflare_record.aaaa
}
