resource "aws_ecr_repository" "backend" {
<<<<<<< HEAD
  name                 = "${var.project}-ecr-${var.env}"
=======
  name                 = "${var.project}-${var.web_container_name}"
>>>>>>> refs/remotes/origin/main
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
