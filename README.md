# Server deployment tools

There are two main entrypoints:

- `setup.yml` - An Ansible playbook that configures a freshly provisioned server.
- `docker-compose.yml` - Docker-compose is used to deploy applciations to the server.

The project uses [git-crypt](https://github.com/AGWA/git-crypt) to store secrets.

## Basic system setup (`setup.yml`)

The goal of `setup.yml` is to automate the regular system maintenance and expose a Docker daemon on a fresh server. The configuration variables are located in `inventory.yml`.

At a high level, it performs the following actions:

- Configures a trusted SSH CA and signs the host keys with it for bidirectional authentication.
- Secures SSH access (no passwords; no root access).
- Configures unattended upgrades for system packages.
- Configures UFW as the system firewall.
- Configures automated backups with borgmatic (and restores latest backup if no data found).
- Sets up automatic SSL certificate renewal with certbot (and provisions if none exist).
- Sets up exim4 as MTA to notify about server events.
- Exposes Docker daemon with bidirectional TLS authentication.

### External dependencies

- Server with global DNS name.
- SSH CA private and public keys.
- TLS CA private and public keys.
- Cloudflare API token with Zone:Zone:Read and Zone:DNS:Edit for all zones.
- Borg backup repository.

### Hacks, workarounds and manual intervention

- A few packages (certbot* and borgmatic*) in Debian stable are not recent enough for required features. These applications are provisioned from Debian testing.
- Accessing the remote Docker daemon requires a CA cert despite using system CA signed certs on the remote end. Either the concatenated default cert store or just `/etc/ssl/certs/DST_Root_CA_X3.pem` needs to provided as the CA. The issue of automatically using default certs is tracked in [docker/cli#2468](https://github.com/docker/cli/issues/2468).
- Manual intervention required for configuring automatic backups - root needs SSH access to the backup host. The current backup host doesn't support SSH CA authentication, so this cannot be automated easily.
  - Possibly can rely on Ansible controller having access to backup host (generate and copy public key to controller and then add key to backup host).
  - Alternatively could use a blessed root SSH key that has preconfigured access to backup host.

## Application deployment (`docker-compose.yml`)

The goal of `apps.yml` is to deploy applications on the remote Docker daemon using Docker Compose. The configuration variables are located in `.env`.

The current deployed applications are:

- Mumble server
- Syncthing
- Caddy

### External dependencies

- Password hash and salt for authenticating to the HTTPS server for restricted resources.

## Misc

Other tools:

* `interactive_user.yml` playbook for creating a interactive user on the remote host for manual administration.
* `dc` is a simple wrapper around docker-compose that suppresses spurious TLS warnings caused by using a docker context. The tracking issue is [docker/compose#7441](https://github.com/docker/compose/issues/7441).
