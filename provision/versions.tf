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
