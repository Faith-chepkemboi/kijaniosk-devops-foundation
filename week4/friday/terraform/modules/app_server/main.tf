terraform {
  required_providers {
    multipass = {
      source = "larstobi/multipass"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "local_file" "cloud_init" {
  filename             = "${path.root}/.generated/cloud-init-${var.name}.yaml"
  file_permission      = "0644"
  directory_permission = "0755"
  content = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    ssh_public_key = var.ssh_public_key
  })
}

resource "multipass_instance" "this" {
  name           = var.name
  cpus           = var.cpus
  memory         = var.memory
  disk           = var.disk
  image          = var.image
  cloudinit_file = local_file.cloud_init.filename
}

data "multipass_instance" "this" {
  name       = multipass_instance.this.name
  depends_on = [multipass_instance.this]
}
