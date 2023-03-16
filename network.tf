resource "aws_internet_gateway" "dev-igw" {
    vpc_id = "${aws_vpc.main.id}"
    
    tags = {
        Name = "dev-igw"
    }
}

resource "aws_route_table" "dev-public-crt" {
    vpc_id = "${aws_vpc.main.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.dev-igw.id}" 
    }
    
    tags = {
        Name = "dev-public-crt"
    }
}

resource "aws_route_table_association" "dev-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.dev-subnet-public-1.id}"
    route_table_id = "${aws_route_table.dev-public-crt.id}"
}

resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow from Personal CIDR block"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SSH from Personal CIDR block"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}