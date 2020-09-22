#Security Group for web Servers Elastic Load Balancer
resource "aws_security_group" "web_servers_elb_sg" {
  name        = "web_servers_elb_sg"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
 tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

#Elastic load balancer for Web Servers
resource "aws_elb" "web_servers_elb" {
  name = "web-servers-elb"
  security_groups = [aws_security_group.web_servers_elb_sg.id]
  subnets = aws_subnet.public_subnet_.*.id
  cross_zone_load_balancing   = true

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
}

#Security Group for App Servers Elastic Load Balancer
resource "aws_security_group" "app_servers_elb_sg" {
  name        = "app_servers_elb_sg"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
 tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}
#Elastic load balancer for App Servers
resource "aws_elb" "app_servers_elb" {
  name = "app-servers-elb"
  security_groups = [aws_security_group.app_servers_elb_sg.id]
  subnets = aws_subnet.app_subnet_.*.id
  cross_zone_load_balancing   = true
  internal  = true

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
}
