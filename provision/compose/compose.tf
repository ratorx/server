variable "extra_env" {
  type        = map(string)
  sensitive   = true
  description = "Extra environment variables to pass to docker-compose"
}

variable "app_ports" {
  type = map(object({
    port : number
  }))
  description = "Ports used by docker-compose services"
}

variable "domain_alias_records" {
  type = list(object({
    name     = string
    hostname = string
  }))
  description = "Vanity URL aliases available to applications"
}

variable "server_record" {
  type = object({
    name     = string
    hostname = string
  })
  description = "Server DNS record"
}

output "env" {
  description = "Environment provided to docker-compose"
  sensitive   = true
  value       = local.env
}

output "env_file_path" {
  description = "Path to the written env file"
  value       = local.env_path
}

locals {
  env = merge(
    { for name, port in var.app_ports : "${name}_port" => port.port },
    { for record in var.domain_alias_records : "${record.name}_domain_alias" => record.hostname },
    { main_domain = var.server_record.hostname },
    var.extra_env,
  )
  env_path = "${path.root}/.env"
}

resource "local_file" "docker_compose_env" {
  filename        = local.env_path
  file_permission = "0600"
  content         = join("\n", [for key, val in local.env : "${upper(key)}=\"${val}\""])
}