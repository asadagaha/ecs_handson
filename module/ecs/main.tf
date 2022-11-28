resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster-${var.env}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.project}-task-definition-${var.env}"
  requires_compatibilities = ["FARGATE"]
  cpu    = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      "name": var.web_container_name
      "image": "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.web_container_name}"
      "name": "${var.project}-${var.web_container_name}",
      "image": "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project}-${var.web_container_name}",
      "essential" : true      
      "portMappings": [
        {
          "containerPort": 80
          "hostPort": 80
        }
      ]
      "logConfiguration": {
        "logDriver": "awslogs"
        "options": {
          "awslogs-region": "ap-northeast-1"
          "awslogs-stream-prefix": "ecs"
          "awslogs-group": var.cloudwatch_log_group_for_ecs
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name = "${var.project}-service-${var.env}"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type = "FARGATE"

  desired_count = 1


  network_configuration {
    assign_public_ip = true
    subnets         = [var.subned_public_1a_id, var.subned_public_1c_id]
    security_groups = ["${var.ecs_sg_id}"]
  }

  load_balancer {
      target_group_arn = var.target_group_arn
      container_name   = "${var.project}-${var.web_container_name}"
      container_port   = "80"
    }
}