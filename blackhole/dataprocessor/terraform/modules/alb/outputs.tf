output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_listener_http" {
  value = aws_lb_listener.front_end_http.arn
}

output "alb_listener_https" {
  value = aws_lb_listener.front_end_https.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_hostname" {
  value = aws_lb.main.dns_name
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the ALB"
}
