resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "Project VPC"
  }
}

resource "aws_route_table_association" "dev-crta-public-subnet-1" {
  subnet_id      = aws_subnet.dev-subnet-public-1.id
  route_table_id = aws_route_table.dev-public-crt.id
}

resource "aws_subnet" "dev-subnet-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"
  depends_on = [
    aws_internet_gateway.dev-igw
  ]

  tags = {
    Name = "dev-subnet-public-1"
  }
}

