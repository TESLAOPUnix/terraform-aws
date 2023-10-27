resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "masub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sub_cidr
  availability_zone = var.az
  map_public_ip_on_launch = "true"
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

resource "aws_instance" "example" {
  ami           = var.ami-name
  instance_type = var.inst-type
  subnet_id     = aws_subnet.masub.id
  key_name      = var.key-name
}

