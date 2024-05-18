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
  count = var.count_public_subnets
  vpc_id                  = aws_vpc.vault_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 10 + count.index)
  availability_zone       = element(local.azs, count.index % length(local.azs))
  map_public_ip_on_launch = true

  tags = {
    Name = "public_${count.index + 1}_subnet"
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
  count = var.count_public_subnets
  subnet_id      = aws_subnet.public_vault_subnet[count.index].id
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
  subnet_id     = aws_subnet.public_vault_subnet[0].id

  depends_on = [aws_internet_gateway.IG]
  tags = {
    Name = "nat_gateway"
  }
}
### PRIVATE SUBNET PART ###

resource "aws_subnet" "private_vault_subnet" {
  count                   = var.count_private_subnets
  vpc_id                  = aws_vpc.vault_vpc.id
  availability_zone       = element(local.azs, count.index % length(local.azs))
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