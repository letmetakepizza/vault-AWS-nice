variable "vault_ec2_count" {}
variable "ssh_key_name" {}
variable "instance_type" {}


variable "private_subnet_ids" {}
variable "instance_iam_profile" {}
variable "vault_sg_id" {}

variable "ami" {
  description = "The AMI to use for the EC2 instances. If left blank, the latest Ubuntu 20.04 AMI will be used."
  type        = string
  default     = ""
}