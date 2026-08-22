# add outputs here
// filename: outputs.tf

output "vpc_id" { value = local.vpc_id }
output "subnet_id" { value = local.subnet_id }
output "sg_id" { value = aws_security_group.vm_sg.id }
output "instance_id" { value = aws_instance.vm.id }
output "public_ip" { value = coalesce(try(aws_eip.this[0].public_ip, null), aws_instance.vm.public_ip) }
output "private_ip" { value = aws_instance.vm.private_ip }

