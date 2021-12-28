packer {
  required_plugins {
    hcloud = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/hcloud"
    }
  }
}

variable "os_image" {
  type = string
}

variable "location" {
  type = string
}

variable "server_type" {
  type = string
}

variable "hcloud_ssh_key_name" {
  type = string
}

variable "ssh_key_pair_path" {
  type = string
}

variable "playbook_path" {
  type = string
} 

source "hcloud" "base" {
  image        = "${var.os_image}"
  location     = "${var.location}"
  server_type  = "${var.server_type}"
  // hcloud does not have default ssh_username
  ssh_username = "root"
  snapshot_name = "${var.os_image}-base"
  ssh_keys = ["${var.hcloud_ssh_key_name}"]

  // By default packer creates temporary key using RSA algorithm,
  // which is no longer recommended and not always accepted by the
  // SSH server without additional arguments.
  ssh_private_key_file = "${var.ssh_key_pair_path}"
}

build {
  name = "hcloud-with-ansible"
  sources = [
    "source.hcloud.base"
  ]
  provisioner "ansible" {
    playbook_file = "${var.playbook_path}"
    ssh_authorized_key_file = "${var.ssh_key_pair_path}.pub"
  }
}
