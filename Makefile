.PHONY: init main interactive apps up

ANSIBLE-PLAYBOOK := ansible-playbook
# TODO: Replace when spurious errors fixed
DOCKER-COMPOSE := ./dc

# Application related rules
up:
	$(DOCKER-COMPOSE) up -d --remove-orphans

down:
	$(DOCKER-COMPOSE) down

force_up:
	$(DOCKER_COMPOSE) up -d --force-recreate

# Setup the server
# Special method to override the remote user for 1st invocation
bootstrap:
	$(ANSIBLE-PLAYBOOK) -e 'ansible_ssh_user=root' setup.yml

setup:
	$(ANSIBLE-PLAYBOOK) --skip-tags "private_ca" setup.yml

setup_private_ca:
	$(ANSIBLE-PLAYBOOK) --tags "private_ca" setup.yml

interactive_user:
	$(ANSIBLE-PLAYBOOK) interactive_user.yml