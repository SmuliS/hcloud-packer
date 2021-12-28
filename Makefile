PACKER_TEMPLATE_NAME = hcloud.pkr.hcl

HCLOUD_VERSION = 1.29.0
HCLOUD_TARBALL = https://github.com/hetznercloud/cli/releases/download/v$(HCLOUD_VERSION)/hcloud-linux-amd64.tar.gz
HCLOUD = bin/hcloud

ifndef HCLOUD_SERVER_IMAGE
$(error HCLOUD_SERVER_IMAGE is not set)
endif

ifndef HCLOUD_SERVER_IMAGE
$(error HCLOUD_SERVER_IMAGE is not set)
endif

ifndef HCLOUD_SERVER_LOCATION
$(error HCLOUD_SERVER_LOCATION is not set)
endif

ifndef HCLOUD_SSH_KEY
$(error HCLOUD_SSH_KEY is not set)
endif

ifndef SSH_KEYPAIR_PATH
$(error SSH_KEYPAIR_PATH is not set)
endif

ifndef ANSIBLE_PLAYBOOK_PATH
$(error ANSIBLE_PLAYBOOK_PATH is not set)
endif

.PHONY: build-image 
build-image: 
	packer build \
		-var 'os_image=$(HCLOUD_SERVER_IMAGE)' \
		-var 'server_type=$(HCLOUD_SERVER_TYPE)' \
		-var 'location=$(HCLOUD_SERVER_LOCATION)' \
		-var 'hcloud_ssh_key_name=$(HCLOUD_SSH_KEY)' \
		-var 'ssh_key_pair_path=$(SSH_KEYPAIR_PATH)' \
		-var 'playbook_path=$(ANSIBLE_PLAYBOOK_PATH)' \
		$(PACKER_TEMPLATE_NAME)

.PHONY: start-server
start-server: .tmp/server_ip
.tmp/server_ip: $(HCLOUD)
	$(HCLOUD) server create \
		--name $(HCLOUD_SERVER_NAME) \
		--image  $(HCLOUD_SERVER_IMAGE) \
		--type $(HCLOUD_SERVER_TYPE) \
		--ssh-key $(SSH_KEY) || true

	mkdir -p .tmp
	$(HCLOUD) server describe $(HCLOUD_SERVER_NAME) -o json | jq .public_net.ipv4.ip | tr -d '"' > $@
	@echo Server IP: $(shell cat .tmp/server_ip)

.PHONY: provision-server
provision-server: .tmp/server_ip
	ansible-playbook -i $(shell cat .tmp/server_ip), --user root $(ANSIBLE_PLAYBOOK_PATH)

.PHONY: stop-server
stop-server: $(HCLOUD)
	$(HCLOUD) server delete $(HCLOUD_SERVER_NAME) || true
	rm -f .tmp/server_ip

.PHONY: install-hcloud
install-hcloud: $(HCLOUD)
$(HCLOUD):
	mkdir -p bin
	$(eval TMPDIR := $(shell mktemp -d /tmp/packer-fedora.XXXX))
	wget -qO- $(HCLOUD_TARBALL) | tar -xz -C $(TMPDIR)
	cp $(TMPDIR)/hcloud $@

clean:
	rm -f .tmp/server_ip

clean-all:
	-rm -r .tmp
	-rm -r bin