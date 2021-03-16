# Server deployment tools

There are three main entrypoints:

- `provision.tf` - Terraform is used to provision the infrastructure.
- `setup.yml` - An Ansible playbook that configures a freshly provisioned server.
- `docker-compose.yml` - Docker-compose is used to deploy applications to the server.

The project uses [git-crypt](https://github.com/AGWA/git-crypt) to store secrets.

## Provisioning infrastructure (`provision.tf`)

The goal of `provision.tf` is to create the server and the infrastructure around it. The configuration variables are located in `terraform.tfvars`. It fetches the host to provision from `inventory.yml`.

Currently it manages:

- Creating the server on Hetzner Cloud.
- Creating DNS records on Cloudflare.
- Configuring monitoring on Uptimerobot.

## Basic system setup (`setup.yml`)

The goal of `setup.yml` is to automate the regular system maintenance and setup Docker on a fresh server. The configuration variables are generated by Terraform once `provision.tf` is run. Ansible uses a `misc/terraform_inventory.py` to fetch the remote inventory configured by Terraform. This indirection is necessary to manage everything in one place (e.g. ports are necessary for firewall config as well as monitoring).

At a high level, it performs the following actions:

- Configures a trusted SSH CA and signs the host keys with it for bidirectional authentication.
- Secures SSH access (no passwords; no root access).
- Configures unattended upgrades for system packages.
- Configures UFW as the system firewall.
- Configures automated backups with borgmatic (and restores latest backup if no data found).
- Configures nullmailer to forward email via an external SMTP server.
- Configures Docker.

### External dependencies

- Server provisioned in the previous step.
- SSH CA private and public keys.
- Borg backup repository.

### Hacks, workarounds and manual intervention

- borgmatic in Debian stable is not recent enough for required features. These applications are provisioned from Debian testing.
- Initial bootstrap of the server uses a different SSH key. This is automated using `make bootstrap` target, but it requires a different command to be run. This is because SSH CA has not been configured yet. A special SSH key is used for this, which lives in the repository. The key is hardcoded because Terraform needs a constant key when provisioning access to the server (TODO: look into managing key with Terraform; tricky bit is getting Ansible to use the key).
- Setting up access to the backup host is tricky, since it doesn't have Python, a shell or SSH CA support. Instead, raw scp commands are used to update the authorized_keys. App servers are only allowed to perform borg operations and only on their own backup repository.

## Application deployment (`docker-compose.yml`)

The goal of `apps.yml` is to deploy applications on the remote Docker daemon using Docker Compose. The configuration variables are located in `.env`. This is generated by Terraform once `provision.tf` is run.

The current deployed applications are:

- Mumble server
- Syncthing
- Caddy
- Custom redirector to download the latest GitHub release of an artifact

### External dependencies

- Password hash and salt for authenticating to the HTTPS server for restricted resources.

## Misc

* `interactive_user.yml` playbook for creating a interactive user on the remote host for manual administration.
* docker-compose uses paramiko for SSH. paramiko does not support verifying host keys signed by a CA ([paramiko/paramiko#771](https://github.com/paramiko/paramiko/issues/771)). This results in a warning in docker-compose, where the default behaviour is to ignore host key check failures (sigh...). The warning can be supressed by manually adding host keys to `~/.ssh/known_hosts`.
