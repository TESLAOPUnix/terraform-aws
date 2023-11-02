resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "masub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sub_cidr
  availability_zone = var.az
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "pvtsub" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.masub.id
  route_table_id = aws_route_table.example.id
}


resource "aws_route_table" "pvtsubrtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtsubrtb.id
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.pubnatip.id
  subnet_id     = aws_subnet.masub.id

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "pubnatip" {
   domain = "vpc"

   depends_on = [aws_internet_gateway.gw]
}

resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }      
}

resource "aws_security_group" "allow_tls_db" {
  name        = "allow_tls_db"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }      
}

resource "aws_instance" "example" {
  ami           = var.ami-name
  instance_type = var.inst-type
  subnet_id     = aws_subnet.masub.id
  key_name      = var.key-name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
}

resource "aws_instance" "db" {
  ami = var.ami-name
  instance_type = var.inst-type
  subnet_id = aws_subnet.pvtsub.id
  key_name = var.key-name
  vpc_security_group_ids = [aws_security_group.allow_tls_db.id]
}







