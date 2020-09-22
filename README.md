# Challenge 1: 3-tier-environment-Terraform

## Description:
This TF script will deploy a single region highly available 3 tier environment contaning EC2, RDS, VPC, ELB, ASG.

# Before you begin:
Create SSH Key-Pairs:
ssh-keygen -f <path to key file and name prefix> -t rsa -b 2048
Two files will be created:
 - no suffix file - the private key
 - .pub suffix - the public key. This is the file you pass in tfvars
  
 Configure AWS cli on your system and store the credentials on default location or you can pass the secret and access key in tfvars(not recommended)
 
  ### Networks to be provisioned:
- 1 VPC 
- 3 Database subnets 
- 3 Web subnets 
 -3 App subnets 
- 3  public subnets
    - Web tier elb,nat gatewayand bastion server 
- 1 internet gateway
- 1 nat gateway
- 2 route table

### Resources:
- 2 ELB (Web tier and app tier)
    - web_servers_elb : Exposed to public interface to provide high availability to front of website
    - app_servers_elb : Exposed to private interface to provide high availability for backend.
- 2 web servers (Amazon linux ) (No of servers and os  can be changed  can be changed in tfvars as they are part of auto scaling group) 
- 2 App Servers (Amazon linux ) No of servers and os can be changed  can be changed in tfvars as they are part of auto scaling group) 
- 1 RDS instance (MySQL 5.7) (You can change the database type in rds.tf)
- 2 Launch Cnfiguration (web and app tier) you can change the launch configuration for web and app tier differntly webasg.tf and appasg.tf and provid ami id and instance type in tfvars
- 2 Auto Scaling Group (web and app tier) you can change the launch configuration for web and app tier differntly webasg.tf and appasg.tf and provide max, min, desired no of server in tfvars
### Few Points:
- All the resources have default value stored in tfvars file , you can simply download and set up your 3-tier in one go
- This is high level architecture view for 3-tier environment not all the option are used. 
- RDS: mysql version 5.7 is being used by default you can change in rds.tf
- Cidr block :- By Default vpc cidr is taken as /16 and can be chnaged , but make sure you are making changes in vpc.tf as subnets are defines in /24.
- Availability Zone : Each subnet is assigned one availability zone with cidr block as /24. Ypu can change number of az and subnets for each tier in tfvars
- Region : you can change region in tfvars file by default its ap-south-1
- Security groups have essential rules only you can edit as per your req.

### Tested on Terraform 13.2
