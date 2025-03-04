resource "aws_instance" "bh" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.large"
  subnet_id     = ${var.subnet_id}
  vpc_security_group_ids = ["${var.security_group_id}"]
  key_name      = ${var.key_name}
  
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name = "bh"
    "Environment" = "Production"
  }
}