# #########################
# Output the ALB DNS

output "alb_dns" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}
