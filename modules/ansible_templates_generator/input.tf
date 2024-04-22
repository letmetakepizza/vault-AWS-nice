variable "vault_instance_public_ip" {}   # For vault.hcl; from ec2-vault
variable "vault_instance_private_ip" {}  # For vault.hcl; from ec2-vault

variable "bastion_public_ip" {}          # For invenotry; from ec2-bastion

variable "region" {}                     # expect to get value from data.aws_region.current (root level)
variable "vault_ec2_count" {}            # Global
variable "ssh_key_name" {}               # Global