data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]  # Canonical
}

resource "aws_instance" "vault_ec2" {
  count = var.vault_ec2_count

  ami = var.ami != "" ? var.ami : data.aws_ami.ubuntu.id
  iam_instance_profile = var.instance_iam_profile
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  
  subnet_id = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids = [ var.vault_sg_id ]
  
  associate_public_ip_address = true

  tags = {
    Name = "Vault_node-${ count.index + 1 }"
    Role = "vault_cluster"
  }
}