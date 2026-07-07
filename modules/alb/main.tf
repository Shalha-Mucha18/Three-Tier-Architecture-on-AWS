# Target group the ASG instances will register with
resource "aws_lb_target_group" "web_tg" {
  name                 = "WebTG"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.dereg_delay

  tags = {
    Name = "WebTG"
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "WebALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "WebALB"
  }
}

# HTTP listener forwarding to the target group
resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
