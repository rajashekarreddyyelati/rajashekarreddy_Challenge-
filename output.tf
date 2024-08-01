output "private_key_pem" {
  value = module.ec2.ec2-key
  sensitive =true
}
output "ec2-ip" {
  value = module.ec2.ec2-ip
}