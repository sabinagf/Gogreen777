resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon-linux2.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_key_pair.key_name
  #   subnet_id                   = aws_subnet.bastion_subnet.id
  subnet_id                   = aws_subnet.public_subnets["Public_Sub_WEB_1A"].id
  vpc_security_group_ids      = [module.bastion_security_group.security_group_id["bastion_sg"]]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
