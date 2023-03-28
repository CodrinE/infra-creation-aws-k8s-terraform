
resource "aws_eip" "demo-eip" {
  vpc               = true
  network_interface = aws_network_interface.demo-nic.id
  tags = {
    Name = "Application-ip"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_network_interface" "demo-nic" {
  subnet_id       = aws_subnet.dev-subnet-public-1.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.jenkins-sg.id]
  tags = {
    NAME = "Application-nic"
  }
}

resource "aws_route_table" "dev-public-crt" {
  vpc_id = aws_vpc.main.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0" //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-crt"
  }
}


resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins Traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_security_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
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