
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2.public_key_openssh

  tags = merge(
    var.tags,
    {
      Name        = "${var.key_name}-ssh-key"
      Exposure    = "private"
      Description = "ssh key"
    }
  )
}
