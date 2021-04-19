resource "hcloud_firewall" "main_firewall" {
  name = var.hostname

  rule {
    direction = "in"
    protocol = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  dynamic "rule" {
    for_each = var.firewall_ports

    content {
      direction = "in"
      protocol  = rule.value.protocol
      port      = rule.value.port
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }
}
