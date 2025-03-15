
resource "libvirt_volume" "os_disk" {
  name   = "${var.vm_name}-${basename(var.os_image_path)}"
  source = var.os_image_path
}
