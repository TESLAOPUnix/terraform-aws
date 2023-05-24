resource "aws_instance" "dove-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1
  key_name               = "dove"
  vpc_security_group_ids = ["sg-0eec2471b2f16c919"]
  tags = {
    Name    = "dove"
    Project = "terr"
  }
}

