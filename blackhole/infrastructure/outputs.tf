output "active_instance_id" {
  description = "The ID of the active EC2 instance in the blue-green deployment"
  value       = module.blue_green.active_instance_id
}
