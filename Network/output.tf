output "public_subnet_id" {
  value = aws_subnet.PublicSubnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.PrivateSubnet[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}