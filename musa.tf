# Defining the provider

provider "aws" {
  region = var.region
}


# Create the VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom-vpc"
  }
}

# Create an Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "custom-igw"
  }
}

# Create an IGW attachment to VPC

resource "aws_internet_gateway_attachment" "igw-attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id = aws_vpc.main.id
}



# Create a public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet1_cidr_block
  availability_zone = var.public_subnet1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

# Create a public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet2_cidr_block
  availability_zone = var.public_subnet2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# create route table for the public subnets 1
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate the public route table with the public subnets 1
resource "aws_route_table_association" "public_rt_assoc_1" {

  depends_on = [aws_subnet.public_subnet_1]
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate the public route table with the public subnets 2
resource "aws_route_table_association" "public_rt_assoc_2" {
  depends_on = [aws_subnet.public_subnet_2]
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
} 

# Create  private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet1_cidr_block
  availability_zone = var.private_subnet1_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

# Create  private subnet 2

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet2_cidr_block
  availability_zone = var.private_subnet2_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}

# Create an EIP for the NAT Gateway
resource "aws_eip" "ngw_eip1" {
  domain = "vpc"
  tags = {
    Name = "ngw-eip"
  }
}

resource "aws_eip" "ngw_eip2" {
  domain = "vpc"
  tags = {
    Name = "EIP2"
  }
}

# Create a NAT Gateway in the public subnet 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.ngw_eip1.id
  subnet_id = aws_subnet.public_subnet_1.id
  tags = {
    Name = "ngw-1"
  }
}

# Create a NAT Gateway in the public subnet 2
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.ngw_eip2.id
  subnet_id = aws_subnet.public_subnet_2.id
  tags = {
    Name = "ngw-2"
  }
}

# Create the route table for the private subnets 1
resource "aws_route_table" "private_rt-1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw1.id
  }
  tags = {
    Name = "private-rt-1"
  }
}

# Create the route table association for the private subnets 1
resource "aws_route_table_association" "private_rt_assoc_1" {
  depends_on = [aws_subnet.private_subnet_1]
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt-1.id
}

# Create the route table for the private subnets 2
resource "aws_route_table" "private_rt-2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw2.id
  }
  tags = {
    Name = "private-rt-2"
  }
}

# Create the route table association for the private subnets 2
resource "aws_route_table_association" "private_rt_assoc_2" {
  depends_on = [aws_subnet.private_subnet_2]
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt-2.id
}

# Create the webSG security group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id 

    tags = {
    Name = "WebSG"
  }

}


# note the resource to create an ingress rule in the webSG security group

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
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id
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

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ALB" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# Crerate the IAM role EC２-ssm

resource "aws_iam_role" "EC2_SSM" {
  name                = "EC2_SSM"
  # the below line attaches the trust policy to the IAM role
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json 

    tags = {
    Name = "EC2_SSM"
  }
}

＃  Create the profile and attach the role EC2-SSM to the profile
resource "aws_iam_instance_profile" "EC2_SSM_profile" {
  name = "Launch the template with the profile"
  role = aws_iam_role.EC2_SSM.name
  tags = {
    Name = "EC2_SSM_profile"
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

# Create the IAM role persmission pilocy to allow the EC2 instance to use SSM service

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

# Attach the created IAM policy to the IAM role EC2-SSM

resource "aws_iam_role_policy" "EC2_SSM_policy" {
  name   = "EC2_SSM_policy"
  role   = aws_iam_role.EC2_SSM.id
  policy = data.aws_iam_policy_document.managed_policy.json
}


## Attach the IAM policy SSM managed policy to the IAM role EC2-SSM

resource "aws_iam_role_policy_attachment" "EC2_SSM_managed_policy" {
  role       = aws_iam_role.EC2_SSM.name
  policy_arn = aws_iam_policy.SSM_policy.arn
}


# Create the target group and ALB

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
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "WebALB"
  }
}

#  Create the ALB listener for Port 80 HTTP with a forwarding rule to WebTG and link the listener to the ALB

resource "aws_lb_listener" "WebALB_listener" {
  load_balancer_arn = aws_lb.WebALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WebTG.arn
  }
}

# Create the launch template and auto scaaling group

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
