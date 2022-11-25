resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/${var.env}/for_ecs"
  retention_in_days = 180
}

output "cloudwatch_log_group_for_ecs" {
  value       = aws_cloudwatch_log_group.for_ecs.name
}
