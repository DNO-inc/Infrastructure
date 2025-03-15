
data "template_file" "admin_user_public_key" {
  template = file(var.admin_user_public_key)
}

data "template_file" "cloudinit_template" {
  template = templatefile(
    var.cloudinit_template_path,
    {
      admin_user_public_key = data.template_file.admin_user_public_key.rendered
    }
  )
}

resource "libvirt_cloudinit_disk" "os_cloudinit" {
  name      = "${var.vm_name}-${basename(var.cloudinit_template_path)}"
  user_data = data.template_file.cloudinit_template.rendered
}
