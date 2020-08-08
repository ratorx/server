# Server deployment tools

There are two main entrypoints, which are both Ansible playbooks:

- `setup.yml` - setup the system configuration on a fresh server.
- `apps.yml` - wrapper for docker-compose which allows access to vaulted secrets.

## Basic system setup

The goal of `setup.yml` is to automate the regular system maintenance and expose a Docker daemon.

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

## Application deployment

The goal of `apps.yml` is to deploy applications on the remote using Docker Compose. The current applications are:

- Mumble server
- Syncthing
- HTTP(S) server and proxy

### External dependencies

- Password hash and salt for authenticating to the HTTPS server for restricted resources.

## Misc

There is also the `interactive_user.yml` playbook for creating a interactive user on the remote host for manual administration.
