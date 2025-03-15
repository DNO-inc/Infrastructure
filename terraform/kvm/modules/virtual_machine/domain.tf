
resource "libvirt_domain" "vm" {
  name = var.vm_name

  cloudinit = libvirt_cloudinit_disk.os_cloudinit.id

  vcpu   = var.vcpu
  memory = var.memory

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id = libvirt_network.base_net.id
  }

  disk {
    volume_id = libvirt_volume.os_disk.id
    scsi      = true
  }
}
