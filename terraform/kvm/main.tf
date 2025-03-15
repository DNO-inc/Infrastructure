terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


module "tres_burrito" {
  source                  = "./modules/virtual_machine"
  cloudinit_template_path = "${path.module}/config/cloudinit.yaml"
  vm_name                 = "tres_burrito_vm"
  memory                  = "2024"
  vcpu                    = 4
  os_image_path           = "${var.os_images_folder}/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
  admin_user_public_key   = "${var.certs_folder}/id_ed25519.pub"
}


module "dbs" {
  source                  = "./modules/virtual_machine"
  cloudinit_template_path = "${path.module}/config/cloudinit.yaml"
  vm_name                 = "dbs_vm"
  memory                  = "2024"
  vcpu                    = 4
  os_image_path           = "${var.os_images_folder}/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
  admin_user_public_key   = "${var.certs_folder}/id_ed25519.pub"
}
