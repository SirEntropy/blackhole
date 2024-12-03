# outputs.tf
output "blue_instance_id" {
  description = "The ID of the blue EC2 instance"
  value       = aws_instance.blue.id
}

output "green_instance_id" {
  description = "The ID of the green EC2 instance"
  value       = aws_instance.green.id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}