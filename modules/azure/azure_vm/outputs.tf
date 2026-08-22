# add outputs here
// filename: outputs.tf

output "subnet_id" { value = local.subnet_id }
output "nic_id" { value = azurerm_network_interface.nic.id }
output "vm_id" { value = azurerm_linux_virtual_machine.vm.id }
output "public_ip" { value = try(azurerm_public_ip.pip[0].ip_address, azurerm_linux_virtual_machine.vm.public_ip_address, null) }
output "private_ip" { value = azurerm_linux_virtual_machine.vm.private_ip_address }

