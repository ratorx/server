resource "hcloud_ssh_key" "temp" {
  name       = "temp"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_server" "server" {
  name        = var.hostname
  server_type = "cpx11"
  image       = "debian-10"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.temp.id]
}
