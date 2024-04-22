output "bastion_public_ip" {
    value = aws_instance.bastion.*.public_ip
    description = "List of public IPs for bastion host. (1 bastion by default)"
}
output "bastion_private_ip" {
  value = aws_instance.bastion.*.private_ip
}