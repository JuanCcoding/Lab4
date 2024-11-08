#En este modulo crearemos todos nuestra VPC con todos sus recursos necesarios, me parecio mejor (aunque con mas codigo)
#hacerlo de forma individual y no importar un modulo vpc

resource "aws_vpc" "mi_VPC" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true # Enable DNS resolution
  enable_dns_hostnames = true # Enable DNS hostnames
   tags = {
        "Name" = "${var.proyecto}-VPC"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}

#public subnets
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.mi_VPC.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Publica1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.mi_VPC.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Publica2"
  }
}

#private subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.mi_VPC.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Privada 1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.mi_VPC.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Privada 2"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mi_VPC.id

  tags = {
    Name = "Igw"
  }
  depends_on = [aws_vpc.mi_VPC]
}

#elastic ip
resource "aws_eip" "eip1" {
  #count = 2

}

resource "aws_eip" "eip2" {

}

#nat gateway
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat2"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "nat1"
  }
  depends_on = [aws_internet_gateway.igw]
}

#public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mi_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

#private route table1
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.mi_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "private-rt"
  }
}

#private route table2
resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.mi_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "private-rt"
  }
}

#route table association
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}
