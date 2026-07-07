output "asg_name" {
  description = "Name of the Auto Scaling group"
  value       = aws_autoscaling_group.web_asg.name
}
