locals {
   vpc_name = "${var.provision_name}-vpc"
}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  tags = {
    Owned-by = var.Owner
    Name = local.vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnet = [cidrsubnet(var.vpc_cidr,8,1),cidrsubnet(var.vpc_cidr,8,3)]
  private_subnet = [cidrsubnet(var.vpc_cidr,8,2),cidrsubnet(var.vpc_cidr,8,4)]
  az = data.aws_availability_zones.available.names
}

resource "aws_subnet" "PublicSubnet" {
  count = length(local.public_subnet)
   vpc_id = aws_vpc.main.id
   availability_zone = element(local.az,count.index)
   cidr_block = element(local.public_subnet,count.index)
   map_public_ip_on_launch = true
   tags = {
      Name = "public-subnet-${count.index}"
      Owned = var.Owner
   }
}

resource "aws_subnet" "PrivateSubnet" {
  count = length(local.private_subnet)
   vpc_id = aws_vpc.main.id
   availability_zone = element(local.az,count.index)
   cidr_block = element(local.private_subnet,count.index)
   map_public_ip_on_launch = true
   tags = {
      Name = "private-subnet-${count.index}"
      Owned = var.Owner
   }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.provision_name}-igw"
  }
}

resource "aws_route_table" "Public-route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "${var.provision_name}-Public-route"
  }
}

resource "aws_route_table_association" "routetable-association" {
  count = length(aws_subnet.PublicSubnet[*].id)
  subnet_id      = element(aws_subnet.PublicSubnet[*].id, count.index)
  route_table_id = aws_route_table.Public-route.id
}


resource "aws_eip" "one" {
  domain = "vpc"
  tags = {
    Name = "${var.provision_name}-NAT-EIP"
  }
}
resource "aws_nat_gateway" "NAT" {
  subnet_id = aws_subnet.PublicSubnet[0].id
  connectivity_type = "public"
  allocation_id = aws_eip.one.allocation_id
  tags = {
   Name = "${var.provision_name}-nat"
  }
  depends_on = [aws_eip.one]
}


resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }
  depends_on = [ aws_nat_gateway.NAT ]
}

resource "aws_route_table_association" "private-route-table-assoscitation" {
  count = length(aws_subnet.PrivateSubnet[*].id)
  subnet_id = element(aws_subnet.PrivateSubnet[*].id,count.index)
  route_table_id = aws_route_table.private-route-table.id
}

