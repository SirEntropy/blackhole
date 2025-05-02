
resource "aws_instance" "EC2-West" {
  ami           = "ami-0d9858aa3c6322f73"
  instance_type = "t3.small"
  subnet_id     = subnet-0e9ebe6de2d761c4f
  vpc_security_group_ids = ["sg-02fbd6fcec94d8ee9"]
  key_name      = None

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = false
  }

  tags = {
    Name = "EC2-West"
    Purpose = "Nothing"
  }
}

