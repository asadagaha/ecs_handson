resource "aws_lb" "main" {
  name                       = "${var.project}-alb-${var.env}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${var.alb_sg_id}"]
  subnets                    = [var.subned_public_1a_id, var.subned_public_1c_id]
  enable_deletion_protection = false
 
  tags = {
    Env = "${var.project}-alb"
  }
}
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  #port              = "443"
  #protocol          = "HTTPS"
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = local.arm_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.id
  }

  condition {
    path_pattern {
        values = ["*"]
    }
  }
}

resource "aws_lb_target_group" "main" {
  name = "${var.project}-alb-tg-${var.env}"
  vpc_id = var.vpc_id
  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
  health_check {
    port = 80
    path = "/"
  }
  depends_on = [aws_lb.main]
}
