
output "EC2-West_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.EC2-West.id
}

output "EC2-West_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.EC2-West.private_ip
}

