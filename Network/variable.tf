variable "vpc_cidr" {
  type = string
  default ="10.0.0.0/16"
}
variable "enable_dns_hostnames" {
  type = bool
  default = false
}
variable "enable_dns_support" {
  type = bool
  default = false
}
variable "provision_name" {
    type = string  
}
variable "Owner" {
  type = string
  description = "Owner tags"
}

variable "instance_tenancy" {
  type = string
  default = "default"
}