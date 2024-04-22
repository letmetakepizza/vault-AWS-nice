data "aws_availability_zones" "available" {}
locals {
  azs = data.aws_availability_zones.available.names
}

resource "aws_vpc" "vault_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main_vault_vpc"
  }
}

### PUBLIC SUBNET PART ###

resource "aws_subnet" "public_vault_subnet" {
  vpc_id                  = aws_vpc.vault_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_theonly_vault_subnet"
    type = "public"
  }
}

resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.vault_vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vault_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
  depends_on = [aws_internet_gateway.IG]

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_vault_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "eip_for_nat" {
  domain = "vpc"
  tags = {
    Name = "eip_for_vpc"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip_for_nat.id
  subnet_id     = aws_subnet.public_vault_subnet.id

  depends_on = [aws_internet_gateway.IG]
  tags = {
    Name = "nat_gateway"
  }
}
### PRIVATE SUBNET PART ###

resource "aws_subnet" "private_vault_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vault_vpc.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 100)
  map_public_ip_on_launch = false

  tags = {
    Name = "private_${count.index + 1}_vault_subnet"
    type = "private"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vault_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  depends_on = [aws_internet_gateway.IG]

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(aws_subnet.private_vault_subnet.*.id)
  subnet_id      = aws_subnet.private_vault_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}


### DATABASE SUBNET PART ###
# resource "aws_subnet" "database_isolated_subnet" {
#   vpc_id                  = aws_vpc.vault_vpc.id
#   availability_zone       = local.azs[0]
#   cidr_block              = cidrsubnet(var.vpc_cidr, 8, 222)
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "private_database_subnet"
#     type = "privateDB"
#   }
# }

# resource "aws_route_table" "database_private" {           # empty RouteTable ensures no external network access
#   vpc_id = aws_vpc.vault_vpc.id
# }

# resource "aws_route_table_association" "database_rt_assoc" { 
#   subnet_id      = aws_subnet.database_isolated_subnet.id
#   route_table_id = aws_route_table.database_private.id
# }

# resource "aws_network_acl" "database_subnet_acl" { # additional security layer for database subnet
#   vpc_id = aws_vpc.vault_vpc.id

#   egress {
#     protocol   = "-1"
#     rule_no    = "100"
#     action     = "allow"
#     cidr_block = aws_subnet.private_vault_subnet[0].cidr_block
#     from_port  = 0
#     to_port    = 0
#   }

#   egress {
#     protocol   = "-1"
#     rule_no    = "200"
#     action     = "allow"
#     cidr_block = aws_subnet.private_vault_subnet[1].cidr_block
#     from_port  = 0
#     to_port    = 0
#   }
#   ingress {
#     protocol   = "-1"
#     rule_no    = "110"
#     action     = "allow"
#     cidr_block = aws_subnet.private_vault_subnet[0].cidr_block
#     from_port  = 0
#     to_port    = 0
#   }

#   ingress {
#     protocol   = "-1"
#     rule_no    = "210"
#     action     = "allow"
#     cidr_block = aws_subnet.private_vault_subnet[1].cidr_block
#     from_port  = 0
#     to_port    = 0
#   }
#   tags = {
#     Name = "database_subnet_acl"
#     type = "database"
#   }
# }

# resource "aws_network_acl_association" "nacl_subnet_assoc" {
#   network_acl_id = aws_network_acl.database_subnet_acl.id
#   subnet_id      = aws_subnet.database_isolated_subnet.id
# }
