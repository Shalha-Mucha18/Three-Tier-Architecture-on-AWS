# #########################
# Task 7: Output the ALB DNS

output "alb_dns" {
  description = "The DNS name of the ALB"
  value       = aws_lb.WebALB.dns_name
}
