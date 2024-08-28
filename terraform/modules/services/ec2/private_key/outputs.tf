
output "private_key_pem" {
  value     = tls_private_key.ec2.private_key_pem
  sensitive = true
}

output "ssh_key_id" {
  value = aws_key_pair.default.id
}

