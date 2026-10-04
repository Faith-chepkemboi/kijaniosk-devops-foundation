module "servers" {
  source   = "./modules/app_server"
  for_each = var.servers

  name           = "${var.name_prefix}-${each.key}"
  cpus           = each.value.cpus
  memory         = each.value.memory
  disk           = each.value.disk
  image          = var.image
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}
