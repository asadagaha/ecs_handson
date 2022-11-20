variable "env" {}
variable "vpc_id" {}

resource "aws_security_group" "ecs" {
  name        = "${var.env}-ecs-sg"
  description = "${var.env}-ecs-sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.env}-ecs-sg"
  }
}
resource "aws_security_group_rule" "inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group" "alb" {
  name        = "${var.env}-alb"
  description = "${var.env} alb"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.env}-alb-sg"
  }
}
resource "aws_security_group_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

output "ecs_sg_id" {
  value       = aws_security_group.ecs.id
}
output "alb_sg_id" {
  value       = aws_security_group.alb.id
}