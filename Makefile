.PHONY: init main interactive apps up

ANSIBLE-PLAYBOOK := ansible-playbook -i production

# Application related rules
up:
	$(ANSIBLE-PLAYBOOK) apps.yml

down:
	$(ANSIBLE-PLAYBOOK) -e 'state=absent' apps.yml

force_up:
	$(ANSIBLE-PLAYBOOK) -e 'force=true' apps.yml

# Provision the server
# Special method to override the remote user for 1st invocation
bootstrap:
	$(ANSIBLE-PLAYBOOK) -e 'ansible_ssh_user=root' setup.yml

setup:
	$(ANSIBLE-PLAYBOOK) --skip-tags "private_ca" setup.yml

setup_private_ca:
	$(ANSIBLE-PLAYBOOK) --tags "private_ca" setup.yml

interactive_user:
	$(ANSIBLE-PLAYBOOK) interactive_user.yml