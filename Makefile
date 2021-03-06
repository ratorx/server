.PHONY: up down force_up bootstrap setup setup_private_ca interactive_user provision plan

# TODO: Replace when spurious errors fixed
DOCKER-COMPOSE := docker-compose
ANSIBLE-PLAYBOOK := ansible-playbook
TERRAFORM := terraform

# Application related rules
up:
	DOCKER_BUILDKIT=1 $(DOCKER-COMPOSE) build --pull
	COMPOSE_DOCKER_CLI_BUILD=0 $(DOCKER-COMPOSE) up -d --no-build --remove-orphans

down:
	$(DOCKER-COMPOSE) down

force_up:
	$(DOCKER-COMPOSE) up -d --force-recreate

# Setup the server
# Special method to override the remote user for 1st invocation
bootstrap:
	$(ANSIBLE-PLAYBOOK) -e 'ansible_ssh_user=root ansible_ssh_private_key_file=./misc/ssh/id_ed25519' --tags bootstrap,never setup.yml

setup:
	$(ANSIBLE-PLAYBOOK) --skip-tags private_ca setup.yml

setup_private_ca:
	$(ANSIBLE-PLAYBOOK) --tags private_ca setup.yml

interactive_user:
	$(ANSIBLE-PLAYBOOK) ./misc/interactive_user.yml

# Provision the server
provision:
	$(TERRAFORM) apply

plan:
	$(TERRAFORM) plan -refresh=false 
