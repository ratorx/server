terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 0.13"
}

variable "server_a_record" {
  type = object({
    name     = string
    hostname = string
    value    = string
  })
  description = "DNS A record of the app server"
}

variable "server_aaaa_record" {
  type = object({
    name     = string
    hostname = string
    value    = string
  })
  description = "DNS AAAA record of the app server"
}

variable "backup_config" {
  type = object({
    passphrase       = string
    fqdn             = string
    username         = string
    private_key_path = string
  })
  description = "Backup details for the application server"
  sensitive   = true
}

variable "used_ports" {
  type = map(object({
    port : number
    protocol : string
  }))
  description = "External ports used on the app server"
}

variable "cloudflare_zone" {
  type = object({
    id   = string
    name = string
  })
  description = "Cloudflare zone to authorize the certbot key for"
}
