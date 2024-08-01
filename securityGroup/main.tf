
resource "aws_security_group" "ALBSecurityGroup" {
  name        = "example-sg"
  description = "Allow inbound traffic"
   vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


locals {
  outbound = [
    {
      port : "80",
      protocol : "tcp"
      cidr_block : ["0.0.0.0/0"]
    },
    {
      port : "443",
      protocol : "tcp"
      cidr_block : ["0.0.0.0/0"]
  }]
  inbound = [
    {
      "port" : "22",
      protocol : "tcp"
      cidr_block : ["152.58.196.174/32"]
    },
  ]
}
resource "aws_security_group" "web_server_sg_tf" {
  name        = "web-server-sg-tf"
  description = "Allow HTTPS to web server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [ aws_security_group.ALBSecurityGroup.id ]
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.ALBSecurityGroup.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

