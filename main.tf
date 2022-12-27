provider "aws" {
  region  = "<AWS REGION>"
  profile = "<AWS CONFIG PROFILE>"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  tags = {
    user = "admin"
    name = "main vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    user = "admin"
    name = "Public subnet"
  }
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    user = "admin"
    name = "Private subnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    user = "admin"
    name = "Main VPC igw"
  }
}

resource "aws_eip" "nat-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    user = "admin"
    name = "Nat gateway EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    user = "admin"
    name = "Main VPC nat gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    user = "admin"
    name = "public route table"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    user = "admin"
    name = "private route table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

}


resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}






