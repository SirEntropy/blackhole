
output "astro_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.astro.id
}

output "astro_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.astro.private_ip
}


output "astro_availability_zone" {
  description = "Availability Zone of the EC2 instance"
  value       = aws_instance.astro.availability_zone
}

