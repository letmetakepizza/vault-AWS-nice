### aws settings, vpc module

variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "ssh_key_name" {
  type    = string
  default = "ssh_key"
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