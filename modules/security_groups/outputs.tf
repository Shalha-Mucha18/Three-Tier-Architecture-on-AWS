output "web_sg_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web_sg.id
}

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}
