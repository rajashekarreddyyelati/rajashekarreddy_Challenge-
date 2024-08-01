resource "aws_lb_target_group" "application-target-group" {
  name     = "application-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "application-target-group"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  count = length(var.instance_id)
  target_group_arn = aws_lb_target_group.application-target-group.arn
  target_id        = element(var.instance_id, count.index)
  port             = 80
}

resource "aws_lb" "AppLoadBalancer" {
  name               = "App-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb-sg-id]
  subnets            = var.public-subnets
  enable_deletion_protection = false
  idle_timeout               = 60

  enable_cross_zone_load_balancing = true
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.AppLoadBalancer.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.application-target-group.arn
#   }
# }

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.AppLoadBalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port            = "443"
      protocol        = "HTTPS"
      status_code     = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.AppLoadBalancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ACM_ARN
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.application-target-group.arn
  }
}

