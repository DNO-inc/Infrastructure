
resource "libvirt_network" "base_net" {
  name = "${var.vm_name}-network"

  mode = "bridge"

  addresses = ["192.168.124.1/24"]

  bridge = "virbr0"

  dhcp {
    enabled = true
  }
}
