output "lb_dns_name" {
  description = "DNS name of Application Load Balancer"
  value = aws_alb.vault_alb.dns_name
}