resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.env}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "main" {
    family = "${var.env}-task-definition"
    requires_compatibilities = ["FARGATE"]

    cpu    = "256"
    memory = "512"

    network_mode = "awsvpc"

    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([{
            "name": "apache-hello-world",
            "image": "${var.apache_container_image_uri}",
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ]
        }])
}

resource "aws_ecs_cluster" "main" {
  name = "${var.env}-cluster"
}


resource "aws_ecs_service" "main" {
  name = "${var.env}-service"
  depends_on = [aws_lb_listener_rule.main]

  cluster = aws_ecs_cluster.main.name

  launch_type = "FARGATE"

  desired_count = "2"

  task_definition = aws_ecs_task_definition.main.arn

  network_configuration {
    subnets         = [var.subned_public_1a_id, var.subned_public_1c_id]
    security_groups = ["${var.ecs_sg_id}"]
  }

  load_balancer {
      target_group_arn = aws_lb_target_group.main.arn
      container_name   = var.apache_container_name
      container_port   = "80"
    }
}