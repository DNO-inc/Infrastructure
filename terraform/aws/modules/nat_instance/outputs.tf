
output "nat_instance_interface" {
  value = aws_instance.nat_instance.primary_network_interface_id
}
