
locals {
  key_name = "ec2-instance-key"
}
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.key_name
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "private_instance" {
  count = length(var.private_subnet_id)
  ami                    = var.ami
  instance_type          = var.instance_size
  key_name               = local.key_name
  vpc_security_group_ids = [var.web-app-sg-id]
  subnet_id              = element(var.private_subnet_id,count.index)
  user_data              = <<EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
echo "Starting user data script"
sudo apt-get update -y
sudo apt-get install -y nginx
sudo sh -c 'printf "<html><head><title>Hello World</title></head><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html'
sudo systemctl restart nginx
echo "User data script completed"
EOF
  root_block_device {
    delete_on_termination = true
    tags = {
      "Owner" : var.Owner
    }
    volume_size = "10"
  }
  tags = {
    Name = "private-instance-${count.index}"
  }
  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdh"
    volume_size           = "10"
    volume_type           = "gp2"
    tags = {
      created_by = "terraform"
    }
  }

}



resource "aws_eip" "bar" {
  count = length(aws_instance.private_instance[*].id)
  domain     = "vpc"
  instance   = element(aws_instance.private_instance[*].id,count.index)
  depends_on = [aws_instance.private_instance]
}

