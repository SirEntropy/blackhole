# EC2 instance for algorithm processing
resource "aws_instance" "bh_algo" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  monitoring = true

  tags = {
    Name = "${var.environment}-bh-algo"
  }
}
