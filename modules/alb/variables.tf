variable "vpc_id" {
  description = "ID of the VPC the ALB and target group live in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to place the ALB in"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID to attach to the ALB"
  type        = string
}

variable "dereg_delay" {
  description = "Deregistration delay (seconds) for the target group"
  type        = string
}
