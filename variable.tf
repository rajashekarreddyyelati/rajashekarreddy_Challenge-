variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "provision_name" {
    type = string
    description = "Resource name will be appended with provision name"
}

variable "Owner" {
  type = string
  description = "Owner of the resources"
}
variable "vpc_cidr" {
  type = string
  description = "Cidr range for vpc"
}

variable "cname" {
  type = string
  description = "cname to create a certificate in acm"
}