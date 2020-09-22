#Provision vpc, subnets, igw, and default route-table
#1 VPC - var.compute subnets for each (public, web,app, database)

#provision app vpc

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "My VPC"
  }
}

#create igw
  resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

#create elastic ip
  resource "aws_eip" "nat_gateway_eip" { 
  vpc = true
}
#create nat gateway
  resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.public_subnet_[0].id
  tags = {
    Name = "Nat_Gateway_Default_route"
  }
}


# add dhcp options
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}


# associate dhcp with vpc
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.app_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}


# Number of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

#provision public subnet
resource "aws_subnet" "public_subnet_" {

  count             = var.compute
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc_dhcp_options_association.dns_resolver]
}

#provision webserver subnet
resource "aws_subnet" "web_subnet_" {

  count             = var.compute
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "web_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc_dhcp_options_association.dns_resolver]
}

#provision appservers subnet

resource "aws_subnet" "app_subnet_" {

  count             = var.compute
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "app_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc_dhcp_options_association.dns_resolver]
}

#provision database subnet
resource "aws_subnet" "rds_subnet_" {

  count             = var.compute
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + 30)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "rds_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc_dhcp_options_association.dns_resolver]
}

#default route table

resource "aws_default_route_table" "Private_subnet_route" {
  default_route_table_id = aws_vpc.app_vpc.default_route_table_id
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
  tags = {
    Name = "private_subnet_route_table"
  }
}

# Public subnet route table
resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name = "Public_subnet_route"
  }
}

#route table association for public subnet
resource "aws_route_table_association" "public_subnet_route_table_" {
  count = var.compute
  subnet_id      = element(aws_subnet.public_subnet_.*.id, count.index)
  route_table_id = aws_route_table.public_subnet_route.id
}
#creating key pair
resource "aws_key_pair" "app_keypair" {
  public_key = file(var.app_keypair_path)
  key_name   = var.app_key_name
}