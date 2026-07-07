# AWS Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

# VPC Configuration
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet Configuration
variable "public_subnet1_cidr_block" {
  description = "CIDR block for the first public subnet"
  type        = string

}

variable "public_subnet2_cidr_block" {
  description = "CIDR block for the second public subnet"
  type        = string

}

variable "private_subnet1_cidr_block" {
  description = "CIDR block for the first private subnet"
  type        = string

}

variable "private_subnet2_cidr_block" {
  description = "CIDR block for the second private subnet"
  type        = string

}

# Availability Zones
variable "public_subnet1_az" {
  description = "Availability zone for the first public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet2_az" {
  description = "Availability zone for the second public subnet"
  type        = string
  default     = "us-east-1b"
}

variable "private_subnet1_az" {
  description = "Availability zone for the first private subnet"
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet2_az" {
  description = "Availability zone for the second private subnet"
  type        = string
  default     = "us-east-1b"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

# Auto Scaling Group Configuration
variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

# IAM Role Configuration
variable "instance_profile_role_name" {
  description = "IAM instance profile role name"
  type        = string
  default     = "EC2_SSM"
}


# Target Group configuration
variable "dereg-delay" {
  type    = string
  default = "10"
}
