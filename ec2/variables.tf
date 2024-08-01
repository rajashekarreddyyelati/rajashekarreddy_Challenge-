variable "private_subnet_id" {
  type = list(string)
  description = "private subnet id"
}
variable "vpc_id" {
  type = string
  description = "vpc id"
}

variable "instance_size" {
  type = string
  default = "t2.micro"
}
variable "ami" {
  type = string
  default = "ami-04a81a99f5ec58529"
}

variable "web-app-sg-id" {
  type = string
}

variable "Owner" {
  type = string
}