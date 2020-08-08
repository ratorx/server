variable hostname {
  type = string
}

variable domain {
  type = string
}

variable ssh_public_key_path {
  type = string
}

locals {
  fqdn = "${var.hostname}.${var.domain}"
}
