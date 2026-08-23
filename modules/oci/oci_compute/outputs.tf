# add outputs here
// filename: outputs.tf

output "subnet_id" { value = local.subnet_id }
output "instance_id" { value = oci_core_instance.vm.id }
output "public_ip" {
  value = coalesce(try(oci_core_public_ip.reserved[0].ip_address, null), oci_core_instance.vm.public_ip)
}
output "private_ip" { value = oci_core_instance.vm.private_ip }
