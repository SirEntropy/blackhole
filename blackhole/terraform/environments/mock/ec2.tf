resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type # Desired state for instance type
  subnet_id              = var.subnet_ids[0]     # Deploy into the first provided subnet
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  # key_name               = "your-ssh-key-name" # Optional: Add your SSH key name

  tags = {
    Name = "${var.instance_name_prefix}-ec2"
    # Add other relevant tags
  }

  # Prevent accidental replacement if AMI ID changes slightly on updates
  lifecycle {
    ignore_changes = [ami]
  }
}
