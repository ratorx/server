terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    uptimerobot = {
      source = "louy/uptimerobot"
    }
  }
  required_version = ">= 0.13"
}

variable "alert_contact" {
  type        = object({ id = string })
  description = "uptimerobot_alert_contact to use for monitoring"
}

variable "monitored_ports" {
  type = map(object({
    port = number
  }))
}

variable "server_record" {
  type = object({
    name     = string
    hostname = string
  })
  description = "DNS record of the server to monitor"
}

variable "cloudflare_zone" {
  type = object({
    id   = string
    name = string
  })
  description = "Base Cloudflare zone to create DNS records in"
}

output "status_page_url" {
  description = "URL to the Uptime Robot status page"
  value   = uptimerobot_status_page.main.standard_url
}