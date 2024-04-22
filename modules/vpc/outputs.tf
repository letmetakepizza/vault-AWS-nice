output "vpc_id" {
  description = "vault_vpc id"
  value = aws_vpc.vault_vpc.id
#   value = [for instance in aws_instance.vault_host_res : instance.public_ip]
}

output "public_subnet_ids" {
  description = "public subnets id. by default 1"
  value = aws_subnet.public_vault_subnet.*.id
}

output "private_subnet_ids" {
  description = "private subnets id. by default 2"
  value = aws_subnet.private_vault_subnet.*.id
}

#  output "database_subnet_ids" {
#   description = "database subnet id. by default 1"
#   value = aws_subnet.database_isolated_subnet.*.id
# }