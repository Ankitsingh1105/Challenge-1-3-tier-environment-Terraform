#Create Security group for web servers
resource "aws_security_group" "web_servers_sg" {
  name        = "web_security_group"
  description = "Allow  inbound connections"
  vpc_id = aws_vpc.app_vpc.id

  dynamic "ingress" {
      for_each = [22,80]
      content {
          from_port   = ingress.value
          to_port      = ingress.value
          protocol      = "TCP"
          cidr_blocks    = [var.vpc_cidr]
      }
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

# Web Tier launch configuration
resource "aws_launch_configuration" "web_servers" {
  name_prefix = "web-"
  image_id = var.web_server_ami # Amazon Linux AMI 2018.03.0 (HVM)
  instance_type = var.web_server_instance_type
  key_name = aws_key_pair.app_keypair.key_name
  security_groups = [aws_security_group.web_servers_sg.id]
  associate_public_ip_address = false
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum install httpd -y
                  echo "<p> Test of ELB </p>" > /var/www/html/index.html
                  echo "<p> Test of ELB </p>" > /index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
  lifecycle {
    create_before_destroy = true
  }
}

#Placement group for web tier Auto Scaling
resource "aws_placement_group" "web_placement" {
  name     = "placement_web_tier"
  strategy = var.web_placement_strategy
}

# Web tier Auto Scaling group
resource "aws_autoscaling_group" "web_servers_asg" {
  name                      = "web_servers_asg"
  max_size                  = var.web_servers_asg_max_size
  min_size                  = var.web_servers_asg_min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.web_servers_asg_desired_capacity
  force_delete              = true
  placement_group           = aws_placement_group.web_placement.id
  launch_configuration      = aws_launch_configuration.web_servers.name
  vpc_zone_identifier       = aws_subnet.web_subnet_.*.id
  load_balancers            = [aws_elb.web_servers_elb.id]

  tags = [
    {
      key                 = "Name"
      value               = "Web_Servers"
      propagate_at_launch = true
    }
  ]
}
