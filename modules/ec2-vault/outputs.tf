output "vault_private_ip" {
    value = aws_instance.vault_ec2.*.private_ip
    description = "List of private IPs for vault nodes. (3 nodes by default)"
}

output "vault_public_ip" {
  value = aws_instance.vault_ec2.*.public_ip
  description = "List of public IPs for vault nodes"
}

output "vault_nodes_ids" {
  value = aws_instance.vault_ec2.*.id
}