variable "instance_type" {}
variable "ssh_key_name" {}
variable "bastion_ec2_count" {}

variable "public_subnet_id" {}
variable "bastion_sg" {}

variable "ami" {
  description = "The AMI to use for the EC2 instances. If left blank, the latest Ubuntu 20.04 AMI will be used."
  type        = string
  default     = ""
}