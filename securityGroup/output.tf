output "alb-sg-id" {
  value = aws_security_group.ALBSecurityGroup.id
}
output "web-app-sg" {
  value = aws_security_group.web_server_sg_tf.id
}