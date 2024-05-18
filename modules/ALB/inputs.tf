variable "certificate_arn_lb" {} # Global
variable "alb_sg" {}             # from security_group module
variable "vault_nodes_ids" {}    # from ec2-vault

variable public_subnet_ids {}    # from VPC module
variable "vpc_id" {}
