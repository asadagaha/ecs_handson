resource "aws_lb" "main" {
  name                       = "${var.env}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${var.alb_sg_id}"]
  subnets                    = [var.subned_public_1a_id, var.subned_public_1c_id]
  enable_deletion_protection = false
 
  tags = {
    Env = "${var.env}-alb"
  }
}
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  #port              = "443"
  #protocol          = "HTTPS"
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

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
  name = "${var.env}-alb-tg"
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

output "target_group_arn" {
  value       = aws_lb_target_group.main.arn
}
