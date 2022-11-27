resource "aws_ecr_repository" "backend" {
  name                 = "${var.project}-ecr-${var.env}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
