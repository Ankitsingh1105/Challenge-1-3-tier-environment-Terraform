variable "region" {
  description = "Region name where the vpc has to be created"
}
variable "secret_key" {
  description = "Access key to login in aws cli"
  default = ""
}

variable "access_key" {
  description = "Access key to login in aws cli"
  default=""
}
variable "vpc_cidr" {
  description = "CIDR of the vpc"
}

variable "db_instance_type" {
  description = "Define the type of instance for the db"
}

variable "db_size" {
  description = "Define the size of instance"
}
variable "rds_password" {
  description = "Relational database password"
}

variable "rds_user" {
  description = "Relational user password"
}

#Web servers Variable
variable "web_server_ami" {
  description = "Ami id of webservers"
}
variable "web_server_instance_type" {
  description = "Define the type of instance for the web servers"
}
variable "web_key" {
  description = "ssh key to login in servers"
}
variable "web_servers_asg_max_size" {
  description = "Maximum no of servers in web ASG"
}
variable "web_servers_asg_min_size" {
  description = "Minimum no of servers in web ASG"
}
variable "web_servers_asg_desired_capacity" {
  description = "Desired no of servers in web ASG"
}
variable "web_placement_strategy" {
  description = " Placement strategy for web tier servers" 
}

#App Servers Variable
variable "app_server_ami" {
  description = "Ami id of appservers"
}
variable "app_server_instance_type" {
  description = "Define the type of instance for the app servers"
}

variable "app_servers_asg_max_size" {
  description = "Maximum no of servers in app ASG"
}
variable "app_servers_asg_min_size" {
  description = "Minimum no of servers in app ASG"
}
variable "app_servers_asg_desired_capacity" {
  description = "Desired no of servers in app ASG"
}
variable "app_placement_strategy" {
  description = " Placement strategy for app tier servers" 
}
variable "app_keypair_path" {
  description = "Path where public key is located"
}
variable "app_key_name" {
  description = "Key name"
}
variable "compute" {
  description = "no of availability zones"
}