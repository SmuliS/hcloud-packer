# hcloud-packer

Simple utility to create snapshots to Hetzner Cloud using HashiCorp Packer and Ansible

## Installation

### Depedencies
- [hcloud](https://github.com/hetznercloud/cli)
- [Ansible](https://www.ansible.com/)
- [Packer by HashiCorp](https://www.packer.io/)

### Configuration

Simply run `cp .env.example .env` and fill in the placeholders

Configuration details: 
```
export HCLOUD_TOKEN=<token> # Hetzner Cloud API token
export HCLOUD_SERVER_NAME=<uuid> # Name of the Server to create (e.g. fedora-packer-dev-4a4ef612-381b-4e4e-8529-121cd82cf3d5)
export HCLOUD_SERVER_IMAGE=<image> # ID or name of the Image the Server is created from (e.g. fedora-34)
export HCLOUD_SERVER_TYPE=<server_type> # ID or name of the Server type this Server should be created with (e.g. cpx11)
export HCLOUD_SERVER_LOCATION=<location> # ID or name of Location to create Server in (e.g. hel1)
export HCLOUD_SSH_KEY=<ssh_key> # SSH key name which should be injected into the Server at creation time

export SSH_KEYPAIR_PATH=<ssh_keypair> # e.g. /home/$(whoami)/.ssh/id_ed25519

export ANSIBLE_PLAYBOOK_PATH=<playbook>
```

## Usage

`make build-image` (_default_): Creates a new snapshot

`make create-server`: Start a new development server

`make provision-server`: Run ansible playbook to running development server

`make delete-server`: Delete development server
