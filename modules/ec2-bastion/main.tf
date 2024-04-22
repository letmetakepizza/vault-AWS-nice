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

resource "aws_instance" "bastion" {
  count = var.bastion_ec2_count

  ami = var.ami != "" ? var.ami : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [ var.bastion_sg ]
  
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_host-${ count.index + 1 }"
  }


}