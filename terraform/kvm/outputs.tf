
output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    tres_burrito = module.tres_burrito.vm_ip
    dbs          = module.dbs.vm_ip
  }
}
