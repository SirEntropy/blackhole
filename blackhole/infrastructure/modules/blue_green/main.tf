# Blue-Green Deployment Module

resource "aws_instance" "blue" {
  count                     = var.blue_green_instances
  ami                       = var.ami_id
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  vpc_security_group_ids    = var.vpc_security_group_ids
  iam_instance_profile      = var.iam_instance_profile
  associate_public_ip_address = var.assign_public_ip

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  lifecycle {
    create_before_destroy = true
  }
}

# Output the ID of the active instance
output "active_instance_id" {
  value = aws_instance.blue[0].id
}
