terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
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
