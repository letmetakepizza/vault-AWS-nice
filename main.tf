data "aws_region" "current" {}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
}

module "tls" {
  source          = "./modules/tls"
  vault_ec2_count = var.vault_ec2_count

  vault_private_ip = module.ec2-vault.vault_private_ip

}

module "security_groups" {
  source   = "./modules/security_groups"
  vpc_cidr = var.vpc_cidr

  bastion_private_ip = module.ec2-bastion.bastion_private_ip
  vpc_id             = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"
}

module "ec2-bastion" {
  source = "./modules/ec2-bastion"

  bastion_ec2_count = var.bastion_ec2_count
  ssh_key_name      = var.ssh_key_name
  ami               = "" # if empty - will be canonical ubuntu-focal-20.04-amd64-server-*
  instance_type     = var.instance_type
  bastion_sg        = module.security_groups.bastion_sg_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
}

module "ec2-vault" {
  source = "./modules/ec2-vault"

  vault_ec2_count = var.vault_ec2_count
  ssh_key_name    = var.ssh_key_name
  ami             = ""
  instance_type   = var.instance_type

  instance_iam_profile = module.iam.vault_instance_profile
  vault_sg_id          = module.security_groups.vault_sg_id
  private_subnet_ids   = module.vpc.private_subnet_ids
}

module "ansible_templates_generator" {
  source          = "./modules/ansible_templates_generator"
  vault_ec2_count = var.vault_ec2_count
  ssh_key_name    = var.ssh_key_name
  region          = data.aws_region.current.name

  bastion_public_ip         = module.ec2-bastion.bastion_public_ip
  vault_instance_public_ip  = module.ec2-vault.vault_public_ip
  vault_instance_private_ip = module.ec2-vault.vault_private_ip
}

output "ssh_commands" {
  value       = [for ip in module.ec2-vault.vault_private_ip : "ssh -i ~/.ssh/${var.ssh_key_name} -o ProxyCommand='ssh -W %h:%p -i ~/.ssh/${var.ssh_key_name} ubuntu@${module.ec2-bastion.bastion_public_ip[0]}' ubuntu@${ip}"]
  description = "The only way to establish SSH connections to Vault nodes it's using the bastion host as a proxy"
}

output "vault_restart_command" {
  value       = "ansible vault -m shell -a 'sudo systemctl restart vault'"
  description = "Restart Vault on nodes. Use after initializing the first node to force all others join the cluster"
}