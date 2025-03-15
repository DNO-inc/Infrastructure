
output "vm_ip" {
  value      = libvirt_domain.vm.network_interface[0].addresses[0]
  depends_on = [libvirt_domain.vm]
}
