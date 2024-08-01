# variable "ACM_arn" {
#   type = string
#   nullable = false
# }
variable "vpc_id" {
  type = string
}

variable "public-subnets" {
  type = list(string)
}

variable "instance_id" {
  type = list(string)
}

variable "ACM_ARN" {
  type = string
  description = "ACM CREATED ARN"
}
variable "alb-sg-id" {
  type = string
}