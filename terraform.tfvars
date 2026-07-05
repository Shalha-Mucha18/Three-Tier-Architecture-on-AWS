# AWS Configuration
region  = "us-east-1"
profile = "terraform_dev"

# VPC Configuration
vpc_cidr_block = "10.0.0.0/16"

# Subnet Configuration
public_subnet1_cidr_block = "10.0.10.0/24"
public_subnet2_cidr_block = "10.0.20.0/24"
private_subnet1_cidr_block = "10.0.100.0/24"
private_subnet2_cidr_block = "10.0.200.0/24"

# Availability Zones
public_subnet1_az = "us-east-1a"
public_subnet2_az = "us-east-1b"
private_subnet1_az = "us-east-1a"
private_subnet2_az = "us-east-1b"


# Instance Configuration
instance_type = "t2.micro"


# IAM Role Configuration
instance_profile_role_name = "EC2_SSM"

# Target Group configuration
# Used to minimize the deregistration delay from the default value 300 seconds to 10 seconds to speed up destroying the infrastructure when needed for this project.
dereg-delay = "10"