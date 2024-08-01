module "network" {
  source               = "./Network"
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  provision_name       = var.provision_name
  Owner                = var.Owner
  instance_tenancy     = "default"
}
module "security_groups" {
  source = "./securityGroup"
  vpc_id = module.network.vpc_id
}
module "ec2" {
  source           = "./ec2"
  web-app-sg-id = module.security_groups.web-app-sg
  private_subnet_id = module.network.private_subnet_id
  vpc_id           = module.network.vpc_id
  instance_size    = "t2.micro"
  ami              = "ami-04a81a99f5ec58529"
  Owner            = var.Owner
}
module "acm" {
  source = "./acm"
  Owner = var.Owner
  cname = var.cname
}
module "alb" {
  source         = "./alb"
  vpc_id         = module.network.vpc_id
  public-subnets = module.network.public_subnet_id
  alb-sg-id = module.security_groups.alb-sg-id
  instance_id    = module.ec2.ec2-instance-id
  ACM_ARN = module.acm.certificate_arn
}


resource "null_resource" "validate_deployment" {
  provisioner "local-exec" {
    command = <<EOT
      HTTP_STATUS=$(curl -s -o /dev/null -w %\{http_code\} "http://${module.alb.endpoint}")
      if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Error: Received HTTP status $HTTP_STATUS"
        exit 1
      else
        echo "Success: Received HTTP status $HTTP_STATUS"
      fi
    EOT
  }

  depends_on = [
    module.alb
  ]
}