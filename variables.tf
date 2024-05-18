### aws settings, vpc module

variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "ssh_key_name" {
  type    = string
  default = "ssh_key"
}

variable "certificate_arn_lb" {
  type = string
  description = "Arn of certificate for load balancer (ACM)"
  default = "arn:aws:acm:us-west-2:account-id:certificate/123123-certificate"
}
variable "count_public_subnets" {
  type    = number
  default = 2
}
variable "count_private_subnets" {
  type    = number
  default = 2
}
### ec2-bastion module 
variable "bastion_ec2_count" {
  type    = number
  default = 1
}
### ec2-vault module
variable "vault_ec2_count" {
  type    = number
  default = 3
}

### EC2 Image and Size (ec2-bastion, ec2-vault)
variable "ami" {
  description = "AMI ID. Leave blank to use the latest Ubuntu AMI."
  type        = string
  default     = ""
}
variable "instance_type" {
  type    = string
  default = "t2.micro"

}