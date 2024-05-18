output "bastion_sg_id" {
  description = "id for Bastion host Security Group"
  value = aws_security_group.sg_bastionhost.id
}

output "vault_sg_id" {
  description = "id for Vault nodes Security Group"
  value = aws_security_group.sg_vault_nodes.id
}
output "alb_sg_id" {
  description = "id for ALB Security Group"
  value = aws_security_group.sg_alb.id
}
