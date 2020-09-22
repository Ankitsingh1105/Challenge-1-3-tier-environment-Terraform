resource "aws_security_group" "bastion_servers_sg" {
  name        = "bastion_security_group"
  description = "To Connect App and web tier"
  vpc_id = aws_vpc.app_vpc.id

  dynamic "ingress" {
      for_each = [3389,80,5985]
      content {
          from_port   = ingress.value
          to_port      = ingress.value
          protocol      = "TCP"
          cidr_blocks    = ["0.0.0.0/0"]
      }
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_eip" "bastion_eip" {
  depends_on = [aws_internet_gateway.app_igw]
}

resource "aws_eip_association" "myapp_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}
resource "aws_instance" "bastion" {
  ami           = "ami-0f438f5108bf5217e" 
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion_servers_sg.id]
  key_name = aws_key_pair.app_keypair.key_name
  subnet_id              = aws_subnet.public_subnet_[0].id
  get_password_data = "true" 

  tags = {
    Name = "Bastion Server"
  }
}
