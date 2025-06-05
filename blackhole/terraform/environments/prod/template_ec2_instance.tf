resource "aws_instance" "template_ec2_instance" {
  ami           = "<FILL_ME>"         # AMI ID
  instance_type = "<FILL_ME>"         # e.g., t2.micro

  # Optional: add subnet, vpc, tags, etc.
  subnet_id              = "<FILL_ME>"
  vpc_security_group_ids = ["<FILL_ME>"]

  tags = {
    Name = "TemplateEC2Instance"
  }
}
