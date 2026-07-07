variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

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

variable "public_subnet1_az" {
  description = "Availability zone for the first public subnet"
  type        = string
}

variable "public_subnet2_az" {
  description = "Availability zone for the second public subnet"
  type        = string
}

variable "private_subnet1_az" {
  description = "Availability zone for the first private subnet"
  type        = string
}

variable "private_subnet2_az" {
  description = "Availability zone for the second private subnet"
  type        = string
}
