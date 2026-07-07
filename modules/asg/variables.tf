variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name to attach to instances"
  type        = string
}

variable "web_sg_id" {
  description = "Security group ID to attach to instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Auto Scaling group"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN to register instances with"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
}
