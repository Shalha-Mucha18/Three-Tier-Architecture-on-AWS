######
# Defining the provider block

provider "aws" {
  region  = var.region
  profile = var.profile
}

#########################
# Task 1 : Create the VPC and Subnets

# Create the VPC

resource "aws_vpc" "custom_VPC" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "custom_VPC"
  }
}

# Create an Internet Gateway

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "IGW-custom_VPC"
  }
}

# Create an IGW attachment to the VPC

resource "aws_internet_gateway_attachment" "igw-attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id = aws_vpc.custom_VPC.id
}

# Create Public Subnet 1

resource "aws_subnet" "Public_Subnet1" {
  vpc_id              = aws_vpc.custom_VPC.id
  cidr_block          = var.public_subnet1_cidr_block
  availability_zone   = var.public_subnet1_az
  
  tags = {
    Name = "Public_Subnet1"
  }
}

# Create Public Subnet 2

resource "aws_subnet" "Public_Subnet2" {
  vpc_id              = aws_vpc.custom_VPC.id
  cidr_block          = var.public_subnet2_cidr_block
  availability_zone   = var.public_subnet2_az
  
  tags = {
    Name = "Public_Subnet2"
  }
}


# Create a route table for the public subnets

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name      = "Public_RT"

  }
}

# Create route table associations for Public Subnet 1

resource "aws_route_table_association" "public_subnet1" {
  depends_on     = [aws_subnet.Public_Subnet1]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.Public_Subnet1.id
}

# Create route table associations for Public Subnet 2

resource "aws_route_table_association" "public_subnet2" {
  depends_on     = [aws_subnet.Public_Subnet2]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.Public_Subnet2.id
}


# Create the two private subnets
# Create private subnet 1

resource "aws_subnet" "Private_Subnet1" {
  vpc_id              = aws_vpc.custom_VPC.id
  cidr_block          = var.private_subnet1_cidr_block
  availability_zone   = var.private_subnet1_az
  
  tags = {
    Name = "Private_Subnet1"
  }
}

# Create private subnet 2

resource "aws_subnet" "Private_Subnet2" {
  vpc_id              = aws_vpc.custom_VPC.id
  cidr_block          = var.private_subnet2_cidr_block
  availability_zone   = var.private_subnet2_az
  
  tags = {
    Name = "Private_Subnet2"
  }
}

#########################
# Task 2 : Create two NAT Gateways

# Create two Elastic IPs, one for each NAT Gateway

# Create an EIP address

resource "aws_eip" "ngw_eip1" {
  domain = "vpc"
  tags = {
    Name = "EIP1"
  }
}

resource "aws_eip" "ngw_eip2" {
  domain = "vpc"
  tags = {
    Name = "EIP2"
  }
}

# Create a NAT  gateway in the first Public Subnet

resource "aws_nat_gateway" "NATGW1" {
  allocation_id = aws_eip.ngw_eip1.id
  subnet_id     = aws_subnet.Public_Subnet1.id
  tags = {
    Name = "NATGW1"
  }
}

# Create a NAT  gateway in the second Public Subnet

resource "aws_nat_gateway" "NATGW2" {
  allocation_id = aws_eip.ngw_eip2.id
  subnet_id     = aws_subnet.Public_Subnet2.id
  tags = {
    Name = "NATGW2"
  }
}


# Create the route table for private subnet 1

resource "aws_route_table" "private_route_table1" {
  # you can add depends_on here for the NATGW
  vpc_id = aws_vpc.custom_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGW1.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name      = "Private_RT_1"

  }
}

# Create the route table associations for private subnet 1

resource "aws_route_table_association" "private_subnet1" {
  depends_on     = [aws_subnet.Private_Subnet1]
  route_table_id = aws_route_table.private_route_table1.id
  subnet_id      = aws_subnet.Private_Subnet1.id
}


# Create the route table for private subnet 2

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.custom_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGW2.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name      = "Private_RT_2"

  }
}

# Create the route table associations for pivate subnet 2


resource "aws_route_table_association" "private_subnet2" {
  depends_on     = [aws_subnet.Private_Subnet2]
  route_table_id = aws_route_table.private_route_table2.id
  subnet_id      = aws_subnet.Private_Subnet2.id
}



#########################
# Task 3 : Create the two Security Groups

# Create the WebSG security group

resource "aws_security_group" "WebSG" {
  name        = "WebSG"
  description = "Allow HTTP for inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.custom_VPC.id

  tags = {
    Name = "WebSG"
  }
}

# note the resource to create an ingress rule in the security group, which is aws_vpc_security_group_ingress_rule

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# note the resource to create an egress rule in the security group, which is aws_vpc_security_group_egress_rule

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create the ALB security group

resource "aws_security_group" "ALBSG" {
  name        = "ALBSG"
  description = "Allow HTTP for inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.custom_VPC.id

  tags = {
    Name = "ALBSG"
  }
}

# note the resource to create an ingress rule in the security group, which is aws_vpc_security_group_ingress_rule

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_ALB" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


# note the resource to create an egress rule in the security group, which is aws_vpc_security_group_egress_rule

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ALB" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



#########################
# Task 4 : Create the Instance Profile and IAM Role

# The instance profile will be required in the launch template to assign the IAM role to the instance that will be created by the auto scaling group

# Create the profile and attach the role EC2_SSM to it

resource "aws_iam_instance_profile" "LT_profile" {
  name = "Launch_template_profile"
  role = aws_iam_role.EC2_SSM.name
}

# Create the IAM role EC2_SSM

resource "aws_iam_role" "EC2_SSM" {
  name                = "EC2_SSM"
  # the below line attaches the trust policy to the IAM role
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json 

    tags = {
    Name = "EC2_SSM"
  }
}

# Define the trust policy of the IAM role (who can use the role), in this case EC2 service will be using the IAM role. 

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create the IAM role permissions policy document
# This policy document has IAM statements copied using the management console, under IAM , Policies, from the AWS managed policy AmazonEC2RoleforSSM

data "aws_iam_policy_document" "managed_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ds:CreateComputer",
      "ds:DescribeDirectories"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetEncryptionConfiguration",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = ["*"]
  }
}

# Attach the created IAM policy document to the IAM policy resource

resource "aws_iam_policy" "SSM_policy" {
  name        = "EC2_SSM-policy"
  description = "allows EC2 to connect to SSM"
  policy      = data.aws_iam_policy_document.managed_policy.json
}

# Attach the IAM policy SSM_policy to the IAM role

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.EC2_SSM.name
  policy_arn = aws_iam_policy.SSM_policy.arn
}



#########################
# Task 5 : Create the Target Group and Application Load Balancer (ALB)

# Create the Target group

resource "aws_lb_target_group" "WebTG" {
  name     = "WebTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_VPC.id
  deregistration_delay = var.dereg-delay

  tags = {
    Name = "WebTG"
  }
}

# Create the ALB

resource "aws_lb" "WebALB" {
  name               = "WebALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  # the below line enables the ALB on the two Public subnets
  subnets            = [aws_subnet.Public_Subnet1.id, aws_subnet.Public_Subnet2.id]

  tags = {
    Name = "WebALB"
  }
}


# Create the ALB listener for Port 80 HTTP with a forwarding rule to WebTG and link the listener to the ALB

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.WebALB.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WebTG.arn
  }
}

#########################
# Task 6 : Create the Launch Template and Auto Scaling Group
# This template will be used by the auto scaling group (found below) to lauch EC2 instances as the Web/App tier.

# Fetch the AMI for the region based on the below filters
# Amazon 2 Linux

data "aws_ami" "myami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter { 
    name = "root-device-type" 
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create the Launch template

resource "aws_launch_template" "WebLT" {
  name = "Web_Launch_Template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.LT_profile.name
  }

  image_id = data.aws_ami.myami.id
  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.WebSG.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web_App_Tier"
    }
  }

# user data must be base64 encoded, we cannot use the function    file() only below to replace filebase64(...)

  user_data = filebase64("${path.module}/script.sh")
}

 # path.module() dynamically reflects the directory containing the module’s configuration files. Using these functions can be helpful when you need to generate file paths dynamically or when dealing with modularized Terraform projects.


## Create the auto scaling group

 
 # The group will be responsible for launching, terminating, and adding/removing EC2 instances as needed. The group will use the Launch template craeted above. Also, it will use the WebSG security group.
 
resource "aws_autoscaling_group" "ASG" {
  vpc_zone_identifier = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]
  # Enable the ELB health checks for the Auto Scaling
  health_check_type   = "ELB"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  # This line links the Auto Scaling group to the ALB through the WebTG target group
  target_group_arns   = [aws_lb_target_group.WebTG.arn]

  launch_template {
    id      = aws_launch_template.WebLT.id
    version = "$Latest"
  }
}


