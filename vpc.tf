resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    tags = {
      Name = "Project VPC"
    }
}

resource "aws_subnet" "dev-subnet-public-1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block  = var.cidr_block
  map_public_ip_on_launch = "true"
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "dev-subnet-public-1"
  }
}

