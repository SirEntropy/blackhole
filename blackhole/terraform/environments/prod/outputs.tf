output "bh_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.bh.id
}

output "bh_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.bh.private_ip
}

output "bh_availability_zone" {
  description = "Availability Zone of the EC2 instance"
  value       = aws_instance.bh.availability_zone
}