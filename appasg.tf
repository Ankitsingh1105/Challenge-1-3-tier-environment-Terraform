#Create Security group for app servers

resource "aws_security_group" "app_servers_sg" {
  name        = "app_security_group"
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

# App Tier launch configuration
resource "aws_launch_configuration" "app_servers" {
  name_prefix = "app-"
  image_id = var.app_server_ami # Amazon Linux AMI 2018.03.0 (HVM)
  instance_type = var.app_server_instance_type
  key_name = aws_key_pair.app_keypair.key_name
  security_groups = [aws_security_group.app_servers_sg.id]
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
}

#Placement group for App tier Auto Scaling
resource "aws_placement_group" "app_placement" {
  name     = "placement group app tier"
  strategy = var.app_placement_strategy
}

# App tier Auto Scaling group
resource "aws_autoscaling_group" "app_servers_asg" {
  name                      = "app_servers_asg"
  max_size                  = var.app_servers_asg_max_size
  min_size                  = var.app_servers_asg_min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.app_servers_asg_desired_capacity
  force_delete              = true
  placement_group           = aws_placement_group.app_placement.id
  launch_configuration      = aws_launch_configuration.app_servers.name
  vpc_zone_identifier       = aws_subnet.app_subnet_.*.id
  load_balancers            = [aws_elb.app_servers_elb.id]


  tags = [
    {
      key                 = "Name"
      value               = "App_Servers"
      propagate_at_launch = true
    }
  ]
}
