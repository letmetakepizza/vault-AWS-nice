##### BASTION HOST SECURITY GROUP (public subnet) #####
resource "aws_security_group" "sg_bastionhost" {
  name        = "sg_bastionhost"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  tags = {
    Name  = "bastion_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "b_allow_ssh" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_bastionhost.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "b_allow_outtrafic" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.sg_bastionhost.id
  cidr_ipv4         = "0.0.0.0/0"
}

##### VAULT NODES SECURITY GROUP (private subnets) #####

resource "aws_security_group" "sg_vault_nodes" {
  name        = "sg_vault_nodes"
  description = "Security group for Vault Nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name  = "vault_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "v_allow_ssh" {      
  count = length(var.bastion_private_ip)            # in case if we need more than 1 bastion
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_vault_nodes.id
  cidr_ipv4         = "${var.bastion_private_ip[count.index]}/32"  
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_8200" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_vault_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8200
  to_port           = 8200
}

resource "aws_vpc_security_group_ingress_rule" "allow_8201" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_vault_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8201
  to_port           = 8201
}


resource "aws_vpc_security_group_ingress_rule" "ping" {
  ip_protocol = "icmp"
  from_port = -1
  to_port = -1
  security_group_id = aws_security_group.sg_vault_nodes.id
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "v_allow_outtrafic" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.sg_vault_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
}

##### Aplication Load Balancer SG #####
resource "aws_security_group" "sg_alb" {
  name = "sg_loadbalancer"
  description = "Security group for ALB"
  vpc_id = var.vpc_id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
  }
  
  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
  }
}