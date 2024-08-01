
output "ec2-ip" {
  value = aws_eip.bar[*].private_ip
}

output "ec2-key" {
  value = tls_private_key.example.private_key_pem
  sensitive = true
}
output "ec2-instance-id" {
  value = aws_instance.private_instance[*].id
}
