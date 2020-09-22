#make rds subnet group
  resource "aws_db_subnet_group" "rdssubnet" {
  name       = "database subnet"
  #subnet_ids  = [aws_subnet.rds_subnet_[0].id, aws_subnet.rds_subnet_[1].id, aws_subnet.rds_subnet_[2].id]
  subnet_ids = aws_subnet.rds_subnet_.*.id
}


#provision the database
resource "aws_db_instance" "database" {
  identifier             = "database"
  instance_class         = var.db_instance_type
  allocated_storage      = var.db_size
  engine                 = "mysql"
  multi_az               =  true
  apply_immediately      =  false
  name                   = "dev_database"
  password               = var.rds_password
  username               = var.rds_user
  engine_version         = "5.7.21"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rdssubnet.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}

#security group for RDS
resource "aws_security_group" "rds_security_group" {
  name   = "rds_security_group"
  vpc_id = aws_vpc.app_vpc.id

  # connection from with vpc
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}
